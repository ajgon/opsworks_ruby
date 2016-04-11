# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'opsworks_ruby::setup' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |solo_node|
      solo_node.set['deploy'] = node['deploy']
    end.converge(described_recipe)
  end

  before do
    stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app])
    stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([aws_opsworks_rds_db_instance])
    stub_node { |n| n.merge(node) }
  end

  it 'includes recipes' do
    expect(chef_run).to include_recipe('deployer')
  end

  context 'Postgresql + git' do
    it 'installs required packages' do
      expect(chef_run).to install_package('git')
      expect(chef_run).to install_package('libpq-dev')
    end
  end
end
