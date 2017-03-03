# frozen_string_literal: true
require 'spec_helper'

describe 'opsworks_ruby::setup' do
  describe command('ruby -v') do
    its(:stdout) { should match(/2\.4\.0/) }
  end

  describe package('libsqlite3-dev') do
    it { should be_installed }
  end

  describe package('git') do
    it { should be_installed }
  end

  describe package('nginx') do
    it { should be_installed }
  end

  describe package('zlib1g-dev') do
    it { should be_installed }
  end

  describe file('/usr/local/bin/bundle') do
    it { should be_symlink }
  end
end

describe 'opsworks_ruby::configure' do
  context 'webserver' do
    describe file('/etc/nginx/ssl/dummy-project.example.com.key') do
      its(:content) { should include '-----BEGIN RSA PRIVATE KEY-----' }
    end

    describe file('/etc/nginx/ssl/dummy-project.example.com.crt') do
      its(:content) { should include '-----BEGIN CERTIFICATE-----' }
    end

    describe file('/etc/nginx/ssl/dummy-project.example.com.ca') do
      its(:content) { should include '-----BEGIN CERTIFICATE-----' }
    end

    describe file('/etc/nginx/sites-enabled/dummy_project.conf') do
      it { should be_symlink }
    end

    describe file('/etc/nginx/sites-available/dummy_project.conf') do
      its(:content) { should include 'upstream puma_dummy-project.example.com' }
      its(:content) { should include 'ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";' }
      its(:content) { should include 'root /srv/www/dummy_project/current/public;' }
    end
  end

  context 'appserver' do
    describe file('/srv/www/dummy_project/shared/config/puma.rb') do
      its(:content) { should include 'workers 4' }
      its(:content) { should include 'unix:///srv/www/dummy_project/shared/sockets/puma.sock' }
      its(:content) { should include 'environment "production"' }
    end

    describe file('/srv/www/dummy_project/shared/scripts/puma.service') do
      its(:content) { should include 'ENV[\'ENV_VAR1\'] = "test"' }
      its(:content) { should include 'ENV[\'RAILS_ENV\'] = "production"' }
      its(:content) { should include 'PID_PATH="/srv/www/dummy_project/shared/pids/puma.pid"' }
      its(:content) { should include 'def puma_running?' }
    end
  end

  context 'framework' do
    describe file('/srv/www/dummy_project/current/config/database.yml') do
      its(:content) { should include 'adapter: sqlite3' }
    end
  end
end

describe 'opsworks_ruby::deploy' do
  context 'scm' do
    describe file('/tmp/ssh-git-wrapper.sh') do
      its(:content) { should include 'exec ssh -o UserKnownHostsFile=/dev/null' }
    end

    describe file('/srv/www/dummy_project/current/.git') do
      it { should_not exist }
    end
  end

  context 'webserver' do
    describe service('nginx') do
      it { should be_running }
    end
  end

  context 'appserver' do
    describe command('pgrep -f puma | tr \'\n\' \' \'') do
      its(:stdout) { should match(/(?:[0-9]+ ){4}/) }
    end
  end

  context 'framework' do
    describe command('ls -1 /srv/www/dummy_project/current/public/assets/application-*.css*') do
      its(:stdout) { should match(/application-[0-9a-f]{64}.css/) }
      its(:stdout) { should match(/application-[0-9a-f]{64}.css.gz/) }
    end

    describe command('ls -1 /srv/www/dummy_project/current/public/test/application-*.css*') do
      its(:stdout) { should match(/application-[0-9a-f]{64}.css/) }
      its(:stdout) { should match(/application-[0-9a-f]{64}.css.gz/) }
    end
  end
end
