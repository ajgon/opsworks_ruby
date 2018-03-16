# frozen_string_literal: true

#
# Cookbook Name:: opsworks_ruby
# Spec:: deploy
#
# Copyright (c) 2016-2018 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'opsworks_ruby::deploy' do
  let(:chef_runner) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
      deploy = node['deploy']
      deploy['dummy_project']['source'].delete('ssh_wrapper')
      solo_node.set['deploy'] = deploy
    end
  end
  let(:chef_run) do
    chef_runner.converge(described_recipe)
  end
  let(:chef_run_rhel) do
    chef_runner_rhel.converge(described_recipe)
  end
  before do
    stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app])
    stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([aws_opsworks_rds_db_instance])
  end

  it 'includes recipes' do
    expect(chef_run).to include_recipe('opsworks_ruby::configure')
  end

  context 'DEPRECATION' do
    let(:chef_runner) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy['dummy_project']['keep_releases'] = 10
        solo_node.set['deploy'] = deploy
      end
    end
    let(:chef_runner_rhel) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy['dummy_project']['keep_releases'] = 10
        solo_node.set['deploy'] = deploy
      end
    end
    let(:logs) { [] }

    before do
      allow(Chef::Log).to receive(:warn) do |message|
        logs.push message
      end
    end

    after do
      expect(logs).to include(
        'DEPRECATION WARNING: node[\'deploy\'][\'dummy_project\'][\'keep_releases\'] is deprecated ' \
        'and will be removed. Please use node[\'deploy\'][\'dummy_project\'][\'global\'][\'keep_releases\'] instead.'
      )
    end

    it 'debian: Shows warning' do
      chef_run
    end

    it 'rhel: Shows warning' do
      chef_run_rhel
    end
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
        rollback_on_error: true,
        environment: aws_opsworks_app['environment'].merge('RAILS_ENV' => 'staging'),
        ssh_wrapper: '/tmp/ssh-git-wrapper.sh',
        symlinks: {
          'system' => 'public/system',
          'assets' => 'public/assets',
          'cache' => 'tmp/cache',
          'pids' => 'tmp/pids',
          'log' => 'log',
          'test' => 'public/test'
        },
        'create_dirs_before_symlink' => %w[tmp public config ../../shared/cache ../../shared/assets ../shared/test],
        'purge_before_symlink' => %w[log tmp/cache tmp/pids public/system public/assets public/test]
      )

      expect(chef_run).to run_execute('stop unicorn')
      expect(chef_run).to run_execute('start unicorn')
      expect(deploy).to notify('service[nginx]').to(:reload).delayed
      expect(service).to do_nothing
    end

    context 'when the location of the generated Git SSH wrapper is overridden' do
      let(:chef_runner) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
          deploy = node['deploy']
          deploy['dummy_project']['source'].delete('ssh_wrapper')
          deploy['dummy_project']['source']['generated_ssh_wrapper'] = '/var/tmp/my-git-ssh-wrapper.sh'
          solo_node.set['deploy'] = deploy
        end
      end

      it 'creates git wrapper script in the specified location' do
        expect(chef_run).to create_template('/var/tmp/my-git-ssh-wrapper.sh')
      end
    end

    it 'restarts sidekiqs via monit' do
      expect(chef_run).to run_execute("monit restart sidekiq_#{aws_opsworks_app['shortname']}-1")
      expect(chef_run).to run_execute("monit restart sidekiq_#{aws_opsworks_app['shortname']}-2")
    end
  end

  context 'Puma + S3 + Apache + resque' do
    let(:chef_runner) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy['dummy_project']['source'] = {
          'adapter' => 's3',
          'user' => 'AWS_ACCESS_KEY_ID',
          'password' => 'AWS_SECRET_ACCESS_KEY',
          'url' => 'https://s3.amazonaws.com/bucket/project.zip'
        }
        deploy['dummy_project']['appserver']['adapter'] = 'puma'
        deploy['dummy_project']['webserver']['adapter'] = 'apache2'
        deploy['dummy_project']['worker']['adapter'] = 'resque'
        solo_node.set['deploy'] = deploy
      end
    end
    let(:chef_runner_rhel) do
      ChefSpec::SoloRunner.new(platform: 'amazon', version: '2016.03') do |solo_node|
        deploy = node['deploy']
        deploy['dummy_project']['source'] = {
          'adapter' => 's3',
          'user' => 'AWS_ACCESS_KEY_ID',
          'password' => 'AWS_SECRET_ACCESS_KEY',
          'url' => 'https://s3.amazonaws.com/bucket/project.zip'
        }
        deploy['dummy_project']['appserver']['adapter'] = 'puma'
        deploy['dummy_project']['webserver']['adapter'] = 'apache2'
        deploy['dummy_project']['worker']['adapter'] = 'resque'
        solo_node.set['deploy'] = deploy
      end
    end
    let(:tmpdir) { '/tmp/opsworks_ruby' }

    before do
      allow(Dir).to receive(:mktmpdir).and_return(tmpdir)
      stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app(app_source: {})])
    end

    it 'downloads project file from S3' do
      expect(chef_run).to create_s3_file(File.join(tmpdir, 'archive', 'project.zip')).with(
        bucket: 'bucket',
        remote_path: 'project.zip',
        aws_access_key_id: 'AWS_ACCESS_KEY_ID',
        aws_secret_access_key: 'AWS_SECRET_ACCESS_KEY',
        owner: 'deploy',
        group: 'www-data',
        mode: '0600',
        s3_url: 'https://s3.amazonaws.com/bucket'
      )
    end

    it 'creates dummy git repository' do
      expect(chef_run).to run_execute(
        "cd #{File.join(tmpdir, 'archive.d')} && git init && " \
        'git config user.name \'Chef\' && git config user.email \'chef@localhost\' && ' \
        'git add -A && git commit --author=\'Chef <>\' -m \'dummy repo\' -an'
      )
    end

    it 'performs a deploy on debian' do
      deploy_debian = chef_run.deploy(aws_opsworks_app['shortname'])

      expect(deploy_debian).to notify('service[apache2]').to(:reload).delayed
      expect(chef_run).to run_execute('stop puma')
      expect(chef_run).to run_execute('start puma')
    end

    it 'performs a deploy on rhel' do
      deploy_rhel = chef_run_rhel.deploy(aws_opsworks_app['shortname'])

      expect(deploy_rhel).to notify('service[httpd]').to(:reload).delayed
      expect(chef_run_rhel).to run_execute('stop puma')
      expect(chef_run_rhel).to run_execute('start puma')
    end

    it 'restarts resques via monit' do
      expect(chef_run).to run_execute("monit restart resque_#{aws_opsworks_app['shortname']}-1")
      expect(chef_run).to run_execute("monit restart resque_#{aws_opsworks_app['shortname']}-2")
    end
  end

  context 'Thin + delayed_job' do
    let(:chef_runner) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy['dummy_project']['appserver']['adapter'] = 'thin'
        deploy['dummy_project']['worker']['adapter'] = 'delayed_job'
        solo_node.set['deploy'] = deploy
      end
    end
    let(:chef_runner_rhel) do
      ChefSpec::SoloRunner.new(platform: 'amazon', version: '2016.03') do |solo_node|
        deploy = node['deploy']
        deploy['dummy_project']['appserver']['adapter'] = 'thin'
        deploy['dummy_project']['worker']['adapter'] = 'delayed_job'
        solo_node.set['deploy'] = deploy
      end
    end

    it 'performs a deploy on debian' do
      expect(chef_run).to run_execute('stop thin')
      expect(chef_run).to run_execute('start thin')
    end

    it 'performs a deploy on rhel' do
      expect(chef_run_rhel).to run_execute('stop thin')
      expect(chef_run_rhel).to run_execute('start thin')
    end

    it 'restarts delayed_jobs via monit' do
      expect(chef_run).to run_execute("monit restart delayed_job_#{aws_opsworks_app['shortname']}-1")
      expect(chef_run).to run_execute("monit restart delayed_job_#{aws_opsworks_app['shortname']}-2")
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
                                                       aws_opsworks_app.merge(shortname: 'a1', deploy: true),
                                                       aws_opsworks_app.merge(shortname: 'a2', deploy: false),
                                                       aws_opsworks_app.merge(shortname: 'a3', deploy: true)
                                                     ])
    chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
      solo_node.set['lsb'] = node['lsb']
      solo_node.set['deploy'] = { 'a1' => {}, 'a2' => {}, 'a3' => {} }
      solo_node.set['applications'] = %w[a1 a2]
    end.converge(described_recipe)
    service = chef_run.service('puma_a1')

    expect(chef_run).to create_directory('/srv/www/a1/shared')
    expect(chef_run).to create_directory('/srv/www/a1/shared/config')
    expect(chef_run).to create_directory('/srv/www/a1/shared/log')
    expect(chef_run).to create_directory('/run/lock/a1')
    expect(chef_run).to create_directory('/srv/www/a1/shared/scripts')
    expect(chef_run).to create_directory('/srv/www/a1/shared/sockets')
    expect(chef_run).to create_directory('/srv/www/a1/shared/vendor/bundle')
    expect(chef_run).to create_template('/srv/www/a1/shared/config/database.yml')
    expect(chef_run).to create_template('/srv/www/a1/shared/config/puma.rb')
    expect(chef_run).to create_template('/srv/www/a1/shared/scripts/puma.service')
    expect(chef_run).to create_template('/etc/nginx/sites-available/a1.conf')
    expect(chef_run).to create_link('/etc/nginx/sites-enabled/a1.conf')
    expect(chef_run).to enable_logrotate_app('a1-nginx-production')
    expect(chef_run).to enable_logrotate_app('a1-rails-production')

    expect(service).to do_nothing
    expect(chef_run).to deploy_deploy('a1')
    expect(chef_run).not_to deploy_deploy('a2')
  end

  describe 'per-application deploy_dir' do
    before do
      stub_search(:aws_opsworks_app, '*:*').and_return([
                                                         aws_opsworks_app.merge(shortname: 'a1', deploy: true)
                                                       ])
    end

    let(:chef_runner) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        solo_node.set['lsb'] = node['lsb']
        solo_node.set['deploy'] = { 'a1' => {} }
        solo_node.set['deploy']['a1']['global']['deploy_dir'] = deploy_dir if deploy_dir
      end
    end

    context 'when deploy_dir is not specified' do
      let(:deploy_dir) { nil }

      it 'deploys a1 using the default deploy directory of /srv/www' do
        expect(chef_run).to create_directory('/srv/www/a1/shared')
        expect(chef_run).to create_directory('/srv/www/a1/shared/config')
        expect(chef_run).to create_directory('/srv/www/a1/shared/log')
        expect(chef_run).to create_directory('/srv/www/a1/shared/scripts')
        expect(chef_run).to create_directory('/srv/www/a1/shared/sockets')
        expect(chef_run).to create_directory('/srv/www/a1/shared/vendor/bundle')
        expect(chef_run).to create_directory('/run/lock/a1')
        expect(chef_run).to create_template('/srv/www/a1/shared/config/database.yml')
        expect(chef_run).to create_template('/srv/www/a1/shared/config/puma.rb')
        expect(chef_run).to create_template('/srv/www/a1/shared/scripts/puma.service')
      end
    end

    context 'when a deploy_dir is specified' do
      let(:deploy_dir) { '/some/other/path/to/a1' }

      it 'deploys a1 using the provided deploy directory instead' do
        expect(chef_run).to create_directory('/some/other/path/to/a1/shared')
        expect(chef_run).to create_directory('/some/other/path/to/a1/shared/config')
        expect(chef_run).to create_directory('/some/other/path/to/a1/shared/log')
        expect(chef_run).to create_directory('/some/other/path/to/a1/shared/scripts')
        expect(chef_run).to create_directory('/some/other/path/to/a1/shared/sockets')
        expect(chef_run).to create_directory('/some/other/path/to/a1/shared/vendor/bundle')
        expect(chef_run).to create_directory('/run/lock/a1')
        expect(chef_run).to create_template('/some/other/path/to/a1/shared/config/database.yml')
        expect(chef_run).to create_template('/some/other/path/to/a1/shared/config/puma.rb')
        expect(chef_run).to create_template('/some/other/path/to/a1/shared/scripts/puma.service')
      end
    end
  end
end
