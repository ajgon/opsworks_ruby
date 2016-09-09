# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'opsworks_ruby::setup' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
      solo_node.set['deploy'] = node['deploy']
      solo_node.set['lsb'] = node['lsb']
    end.converge(described_recipe)
  end
  let(:chef_run_rhel) do
    ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
      solo_node.set['deploy'] = node['deploy']
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
    context 'Debian' do
      it 'installs ruby 2.0' do
        chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.0' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
        end.converge(described_recipe)

        expect(chef_run).to install_package('ruby2.0')
        expect(chef_run).to install_package('ruby2.0-dev')
      end

      it 'installs ruby 2.1' do
        chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.1' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
        end.converge(described_recipe)

        expect(chef_run).to install_package('ruby2.1')
        expect(chef_run).to install_package('ruby2.1-dev')
      end

      it 'installs ruby 2.2' do
        chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
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

    context 'rhel' do
      it 'installs ruby 2.0' do
        chef_run_rhel = ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.0' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
        end.converge(described_recipe)

        expect(chef_run_rhel).to install_package('ruby20')
        expect(chef_run_rhel).to install_package('ruby20-devel')
        expect(chef_run_rhel).to run_execute('/usr/sbin/alternatives --set ruby /usr/bin/ruby2.0')
      end

      it 'installs ruby 2.1' do
        chef_run_rhel = ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.1' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
        end.converge(described_recipe)

        expect(chef_run_rhel).to install_package('ruby21')
        expect(chef_run_rhel).to install_package('ruby21-devel')
        expect(chef_run_rhel).to run_execute('/usr/sbin/alternatives --set ruby /usr/bin/ruby2.1')
      end

      it 'installs ruby 2.2' do
        chef_run_rhel = ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.2' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
        end.converge(described_recipe)

        expect(chef_run_rhel).to install_package('ruby22')
        expect(chef_run_rhel).to install_package('ruby22-devel')
        expect(chef_run_rhel).to run_execute('/usr/sbin/alternatives --set ruby /usr/bin/ruby2.2')
      end

      it 'installs ruby 2.3' do
        expect(chef_run_rhel).to install_package('ruby23')
        expect(chef_run_rhel).to install_package('ruby23-devel')
        expect(chef_run_rhel).to run_execute('/usr/sbin/alternatives --set ruby /usr/bin/ruby2.3')
      end
    end
  end

  context 'Gems' do
    it 'debian bundler' do
      expect(chef_run).to install_gem_package(:bundler)
      expect(chef_run).to create_link('/usr/local/bin/bundle').with(to: '/usr/bin/bundle')
    end

    it 'rhel bundler' do
      expect(chef_run_rhel).to install_gem_package(:bundler)
      expect(chef_run_rhel).to create_link('/usr/local/bin/bundle').with(to: '/usr/local/bin/bundler')
    end
  end

  context 'Postgresql + git + nginx' do
    it 'installs required packages for debian' do
      expect(chef_run).to install_package('nginx')
      expect(chef_run).to install_package('zlib1g-dev')
      expect(chef_run).to install_package('git')
      expect(chef_run).to install_package('libpq-dev')
    end

    it 'installs required packages for rhel' do
      expect(chef_run_rhel).to install_package('nginx')
      expect(chef_run_rhel).to install_package('zlib-devel')
      expect(chef_run_rhel).to install_package('git')
      expect(chef_run_rhel).to install_package('postgresql94-devel')
    end

    it 'defines service which starts nginx' do
      expect(chef_run).to start_service('nginx')
    end
  end

  context 'Mysql + apache2' do
    before do
      stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([aws_opsworks_rds_db_instance(engine: 'mysql')])
    end

    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy['dummy_project']['webserver']['adapter'] = 'apache2'
        solo_node.set['deploy'] = deploy
      end.converge(described_recipe)
    end

    let(:chef_run_rhel) do
      ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
        deploy = node['deploy']
        deploy['dummy_project']['webserver']['adapter'] = 'apache2'
        solo_node.set['deploy'] = deploy
      end.converge(described_recipe)
    end

    context 'debian' do
      it 'installs required packages' do
        expect(chef_run).to install_package('libmysqlclient-dev')
        expect(chef_run).to install_package('apache2')
      end

      it 'defines service which starts apache2' do
        expect(chef_run).to start_service('apache2')
      end

      it 'enables necessary modules for apache2' do
        expect(chef_run)
          .to run_execute('a2enmod expires headers lbmethod_byrequests proxy proxy_balancer proxy_http rewrite ssl')
      end
    end

    context 'rhel' do
      it 'installs required packages' do
        expect(chef_run_rhel).to install_package('mysql-devel')
        expect(chef_run_rhel).to install_package('httpd24')
        expect(chef_run_rhel).to install_package('mod24_ssl')
      end

      it 'defines service which starts httpd' do
        expect(chef_run_rhel).to start_service('httpd')
      end

      it 'creates sites-* directories' do
        expect(chef_run_rhel).to create_directory('/etc/httpd/sites-available')
        expect(chef_run_rhel).to create_directory('/etc/httpd/sites-enabled')
        expect(chef_run_rhel)
          .to run_execute('echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf')
      end
    end
  end

  context 'Sqlite' do
    temp_node = node['deploy']
    temp_node['dummy_project']['database'] = {}
    temp_node['dummy_project']['database']['adapter'] = 'sqlite'

    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        solo_node.set['deploy'] = temp_node
        solo_node.set['lsb'] = node['lsb']
      end.converge(described_recipe)
    end
    let(:chef_run_rhel) do
      ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
        solo_node.set['deploy'] = temp_node
      end.converge(described_recipe)
    end

    before do
      stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([])
    end

    it 'installs required packages for debian' do
      expect(chef_run).to install_package('libsqlite3-dev')
    end

    it 'installs required packages for rhel' do
      expect(chef_run_rhel).to install_package('sqlite-devel')
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
