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
      its(:content) { should include 'upstream thin_dummy-project.example.com' }
      its(:content) { should include 'ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";' }
      its(:content) { should include 'root /srv/www/dummy_project/current/public;' }
    end
  end

  context 'appserver' do
    describe file('/srv/www/dummy_project/shared/config/thin.yml') do
      its(:content) { should include 'max_conns: 4096' }
      its(:content) { should include 'max_persistent_conns: 2048' }
      its(:content) { should include 'socket: "/srv/www/dummy_project/shared/sockets/thin.sock"' }
    end
  end

  context 'worker' do
    describe file('/etc/monit/conf.d/delayed_job_dummy_project.monitrc') do
      its(:content) { should include 'group delayed_job_dummy_project_group' }
      its(:content) { should include 'check process delayed_job_dummy_project-1' }
      its(:content) do
        should include 'RACK_ENV="production" DATABASE_URL="sqlite:///srv/www/dummy_project/shared/db/data.sqlite3" ' \
                       'HOME="/home/deploy" USER="deploy" bin/delayed_job start ' \
                       '--pid-dir=/run/lock/dummy_project/ -i 0 --queues=default,mailers'
      end
      its(:content) { should include 'logger -t delayed_job-dummy_project-1' }
      its(:content) { should include 'check process delayed_job_dummy_project-2' }
      its(:content) do
        should include 'RACK_ENV="production" DATABASE_URL="sqlite:///srv/www/dummy_project/shared/db/data.sqlite3" ' \
                       'HOME="/home/deploy" USER="deploy" bin/delayed_job start ' \
                       '--pid-dir=/run/lock/dummy_project/ -i 1 --queues=default,mailers'
      end
      its(:content) { should include 'logger -t delayed_job-dummy_project-2' }
    end
  end
end

describe 'opsworks_ruby::deploy' do
  context 'source' do
    describe file('/tmp/ssh-git-wrapper.sh') do
      it { should_not exist }
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
    describe command('pgrep -f thin | tr \'\n\' \' \'') do
      its(:stdout) { should match(/(?:[0-9]+ ){2}/) }
    end
  end
end
