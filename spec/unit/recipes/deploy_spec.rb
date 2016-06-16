# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Spec:: deploy
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'opsworks_ruby::deploy' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
      deploy = node['deploy']
      deploy['dummy_project']['scm'].delete('ssh_wrapper')
      solo_node.set['deploy'] = deploy
    end.converge(described_recipe)
  end
  before do
    stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app])
    stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([aws_opsworks_rds_db_instance])
  end

  it 'includes recipes' do
    expect(chef_run).to include_recipe('opsworks_ruby::configure')
  end

  context 'Postgresql + Git + Unicorn + Nginx + Sidekiq' do
    it 'creates git wrapper script' do
      expect(chef_run).to create_template('/tmp/ssh-git-wrapper.sh')
    end

    it 'adds and destroys ssh deploy key' do
      expect(chef_run).to create_template('/tmp/.ssh-deploy-key')
      expect(chef_run).to delete_file('/tmp/.ssh-deploy-key')
    end

    it 'performs a deploy' do
      deploy = chef_run.deploy(aws_opsworks_app['shortname'])
      service = chef_run.service('nginx')

      expect(chef_run).to deploy_deploy('dummy_project').with(
        repository: 'git@git.example.com:repo/project.git',
        revision: 'master',
        scm_provider: Chef::Provider::Git,
        enable_submodules: false,
        environment: aws_opsworks_app['environment'].merge('RAILS_ENV' => 'production'),
        ssh_wrapper: '/tmp/ssh-git-wrapper.sh',
        symlinks: {
          'system' => 'public/system',
          'assets' => 'public/assets',
          'cache' => 'tmp/cache',
          'pids' => 'tmp/pids',
          'log' => 'log',
          'test' => 'public/test'
        },
        'create_dirs_before_symlink' => %w(tmp public config ../../shared/cache ../../shared/assets ../shared/test),
        'purge_before_symlink' => %w(log tmp/cache tmp/pids public/system public/assets public/test)
      )

      expect(chef_run).to run_execute('stop unicorn')
      expect(chef_run).to run_execute('start unicorn')
      expect(deploy).to notify('service[nginx]').to(:reload).delayed
      expect(service).to do_nothing
    end

    it 'restarts sidekiqs via monit' do
      expect(chef_run).to run_execute('monit reload')
      expect(chef_run).to run_execute("monit restart sidekiq_#{aws_opsworks_app['shortname']}-1")
      expect(chef_run).to run_execute("monit restart sidekiq_#{aws_opsworks_app['shortname']}-2")
    end
  end

  it 'empty node[\'deploy\']' do
    chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
      solo_node.set['lsb'] = node['lsb']
    end.converge(described_recipe)

    expect do
      chef_run
    end.not_to raise_error
  end

  it 'node[\'applications\']' do
    stub_search(:aws_opsworks_app, '*:*').and_return([
                                                       aws_opsworks_app.merge(shortname: 'a1'),
                                                       aws_opsworks_app.merge(shortname: 'a2')
                                                     ])
    chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
      solo_node.set['lsb'] = node['lsb']
      solo_node.set['deploy'] = { 'a1' => {}, 'a2' => {} }
      solo_node.set['applications'] = ['a1']
    end.converge(described_recipe)
    service_a1 = chef_run.service('unicorn_a1')

    expect(chef_run).to create_directory('/srv/www/a1/shared')
    expect(chef_run).to create_directory('/srv/www/a1/shared/config')
    expect(chef_run).to create_directory('/srv/www/a1/shared/log')
    expect(chef_run).to create_directory('/srv/www/a1/shared/pids')
    expect(chef_run).to create_directory('/srv/www/a1/shared/scripts')
    expect(chef_run).to create_directory('/srv/www/a1/shared/sockets')
    expect(chef_run).to create_template('/srv/www/a1/shared/config/database.yml')
    expect(chef_run).to create_template('/srv/www/a1/shared/config/unicorn.conf')
    expect(chef_run).to create_template('/srv/www/a1/shared/scripts/unicorn.service')
    expect(chef_run).to create_template('/etc/nginx/sites-available/a1')
    expect(chef_run).to create_link('/etc/nginx/sites-enabled/a1')
    expect(service_a1).to do_nothing
    expect(chef_run).to deploy_deploy('a1')
    expect(chef_run).not_to deploy_deploy('a2')
  end
end
