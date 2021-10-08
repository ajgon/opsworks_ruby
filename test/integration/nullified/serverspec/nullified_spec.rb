# frozen_string_literal: true

require 'spec_helper'

describe 'opsworks_ruby::setup' do
  describe package('ruby2.7') do
    it { should be_installed }
  end

  describe package('libsqlite3-dev') do
    it { should be_installed }
  end

  describe package('git') do
    it { should be_installed }
  end

  describe package('nginx') do
    it { should_not be_installed }
  end

  describe package('apache2') do
    it { should_not be_installed }
  end

  describe file('/usr/local/bin/bundle') do
    it { should be_symlink }
  end
end

describe 'opsworks_ruby::configure' do
  context 'webserver' do
    describe file('/etc/nginx') do
      it { should_not exist }
    end

    describe file('/etc/apache2/apache2.conf') do
      it { should_not exist }
    end
  end
end

describe 'opsworks_ruby::deploy' do
  context 'source' do
    describe file('/tmp/ssh-git-wrapper.sh') do
      its(:content) { should include 'exec ssh -o UserKnownHostsFile=/dev/null' }
    end

    describe file('/srv/www/dummy_project/current/.git') do
      it { should_not exist }
    end
  end

  context 'webserver' do
    describe service('nginx') do
      it { should_not be_running }
    end

    describe service('apache2') do
      it { should_not be_running }
    end
  end
end
