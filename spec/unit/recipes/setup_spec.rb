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
      solo_node.set['lsb'] = node['lsb']
    end.converge(described_recipe)
  end

  before do
    stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app])
    stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([aws_opsworks_rds_db_instance])
    stub_node { |n| n.merge(node) }
    stub_command('which nginx').and_return(false)
  end

  it 'includes recipes' do
    expect(chef_run).to include_recipe('deployer')
  end

  context 'Rubies' do
    it 'installs ruby 2.0' do
      chef_run = ChefSpec::SoloRunner.new do |solo_node|
        solo_node.set['ruby'] = { 'version' => '2.0' }
        solo_node.set['lsb'] = node['lsb']
        solo_node.set['deploy'] = node['deploy']
      end.converge(described_recipe)

      expect(chef_run).to install_package('ruby2.0')
      expect(chef_run).to install_package('ruby2.0-dev')
    end

    it 'installs ruby 2.1' do
      chef_run = ChefSpec::SoloRunner.new do |solo_node|
        solo_node.set['ruby'] = { 'version' => '2.1' }
        solo_node.set['lsb'] = node['lsb']
        solo_node.set['deploy'] = node['deploy']
      end.converge(described_recipe)

      expect(chef_run).to install_package('ruby2.1')
      expect(chef_run).to install_package('ruby2.1-dev')
    end

    it 'installs ruby 2.2' do
      chef_run = ChefSpec::SoloRunner.new do |solo_node|
        solo_node.set['ruby'] = { 'version' => '2.2' }
        solo_node.set['lsb'] = node['lsb']
        solo_node.set['deploy'] = node['deploy']
      end.converge(described_recipe)

      expect(chef_run).to install_package('ruby2.2')
      expect(chef_run).to install_package('ruby2.2-dev')
    end

    it 'installs ruby 2.3' do
      expect(chef_run).to install_package('ruby2.3')
      expect(chef_run).to install_package('ruby2.3-dev')
    end
  end

  context 'Gems' do
    it 'bundler' do
      expect(chef_run).to install_gem_package(:bundler)
      expect(chef_run).to create_link('/usr/local/bin/bundle')
    end
  end

  context 'Postgresql + git + nginx' do
    it 'installs required packages' do
      expect(chef_run).to install_package('nginx')
      expect(chef_run).to install_package('git')
      expect(chef_run).to install_package('libpq-dev')
    end

    it 'defines service which starts nginx' do
      expect(chef_run).to start_service('nginx')
    end
  end

  it 'empty node[\'deploy\']' do
    chef_run = ChefSpec::SoloRunner.new do |solo_node|
      solo_node.set['lsb'] = node['lsb']
    end.converge(described_recipe)

    expect do
      chef_run
    end.not_to raise_error
  end
end
