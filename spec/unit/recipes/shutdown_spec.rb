# frozen_string_literal: true

#
# Cookbook Name:: opsworks_ruby
# Spec:: shutdown

require 'spec_helper'

describe 'opsworks_ruby::shutdown' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
      solo_node.set['deploy'] = node['deploy']
    end.converge(described_recipe)
  end
  before do
    stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app])
    stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([aws_opsworks_rds_db_instance])
  end

  it 'works' do
    expect do
      chef_run
    end.not_to raise_error
  end

  context 'safely shutdown sidekiq' do
    it 'unmonitors sidekiq processes' do
      expect(chef_run).to run_execute('monit unmonitor sidekiq_dummy_project-1')
      expect(chef_run).to run_execute('monit unmonitor sidekiq_dummy_project-2')
    end

    it 'shutsdown sidekiq processes' do
      expect(chef_run).to(
        run_execute(
          '/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
          'ENV_VAR2="some data" RAILS_ENV="staging" HOME="/home/deploy" USER="deploy" ' \
          'bundle exec sidekiqctl stop /run/lock/dummy_project/sidekiq_dummy_project-1.pid 8\''
        )
      )
      expect(chef_run).to(
        run_execute(
          '/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
          'ENV_VAR2="some data" RAILS_ENV="staging" HOME="/home/deploy" USER="deploy" '\
          'bundle exec sidekiqctl stop /run/lock/dummy_project/sidekiq_dummy_project-2.pid 8\''
        )
      )
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
