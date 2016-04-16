# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Spec:: deploy
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'opsworks_ruby::deploy' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |solo_node|
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

  context 'Postgresql + Git + Unicorn + Nginx' do
    it 'creates git wrapper script' do
      expect(chef_run).to create_template('/tmp/ssh-git-wrapper.sh')
    end

    it 'adds and destroys ssh deploy key' do
      expect(chef_run).to create_template('/tmp/.ssh-deploy-key')
      expect(chef_run).to delete_file('/tmp/.ssh-deploy-key')
    end

    it 'performs a deploy' do
      expect(chef_run).to deploy_deploy('dummy_project').with(
        repository: 'git@git.example.com:repo/project.git',
        revision: 'master',
        scm_provider: Chef::Provider::Git,
        enable_submodules: false,
        ssh_wrapper: '/tmp/ssh-git-wrapper.sh'
      )

      expect(chef_run).to run_execute('stop unicorn')
      expect(chef_run).to run_execute('start unicorn')
    end
  end
end
