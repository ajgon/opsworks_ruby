# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Spec:: undeploy
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'opsworks_ruby::undeploy' do
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

  context 'Postgresql + Git + Unicorn + Nginx + Sidekiq' do
    it 'performs a rollback' do
      undeploy = chef_run.deploy(aws_opsworks_app['shortname'])
      service = chef_run.service('nginx')

      expect(chef_run).to rollback_deploy('dummy_project')
      expect(chef_run).to run_execute('stop unicorn')
      expect(chef_run).to run_execute('start unicorn')

      expect(undeploy).to notify('service[nginx]').to(:restart).delayed
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
end
