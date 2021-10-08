# frozen_string_literal: true

#
# Cookbook Name:: opsworks_ruby
# Spec:: shutdown

require 'spec_helper'

describe 'opsworks_ruby::shutdown' do
  cached(:chef_run) do
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

    it 'quiets sidekiq processes' do
      expect(chef_run).to(
        run_execute(
          '/bin/su - deploy -c "ps -ax | grep \'bundle exec sidekiq\' | ' \
          'grep sidekiq_1.yml | grep -v grep | awk \'{print \\$1}\' | ' \
          'xargs --no-run-if-empty pgrep -P | xargs --no-run-if-empty kill -TSTP"'
        )
      )
      expect(chef_run).to(
        run_execute(
          '/bin/su - deploy -c "ps -ax | grep \'bundle exec sidekiq\' | ' \
          'grep sidekiq_2.yml | grep -v grep | awk \'{print \\$1}\' | ' \
          'xargs --no-run-if-empty pgrep -P | xargs --no-run-if-empty kill -TSTP"'
        )
      )
    end

    it 'shutsdown sidekiq processes' do
      expect(chef_run).to(
        run_execute(
          'timeout 8 /bin/su - deploy -c "ps -ax | grep \'bundle exec sidekiq\' | ' \
          'grep sidekiq_1.yml | grep -v grep | awk \'{print \\$1}\' | ' \
          'xargs --no-run-if-empty pgrep -P | xargs --no-run-if-empty kill"'
        )
      )
      expect(chef_run).to(
        run_execute(
          'timeout 8 /bin/su - deploy -c "ps -ax | grep \'bundle exec sidekiq\' | ' \
          'grep sidekiq_2.yml | grep -v grep | awk \'{print \\$1}\' | ' \
          'xargs --no-run-if-empty pgrep -P | xargs --no-run-if-empty kill"'
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
