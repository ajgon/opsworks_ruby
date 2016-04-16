# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Spec:: undeploy
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'opsworks_ruby::undeploy' do
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

  context 'Postgresql + Git + Unicorn + Nginx' do
    it 'performs a rollback' do
      expect(chef_run).to rollback_deploy('dummy_project')
      expect(chef_run).to run_execute('stop unicorn')
      expect(chef_run).to run_execute('start unicorn')
    end
  end
end
