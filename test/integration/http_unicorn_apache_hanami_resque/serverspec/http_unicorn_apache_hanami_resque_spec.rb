# frozen_string_literal: true

require 'spec_helper'

describe 'opsworks_ruby::setup' do
  describe package('ruby2.6') do
    it { should be_installed }
  end

  describe package('libsqlite3-dev') do
    it { should be_installed }
  end

  describe package('git') do
    it { should be_installed }
  end

  describe package('apache2') do
    it { should be_installed }
  end

  describe package('redis-server') do
    it { should be_installed }
  end

  describe file('/usr/local/bin/bundle') do
    it { should be_symlink }
  end
end

describe 'opsworks_ruby::configure' do
  context 'webserver' do
    describe file('/etc/logrotate.d/dummy_project-apache2-production') do
      its(:content) do
        should include '"/var/log/apache2/dummy-project.example.com.access.log" ' \
                       '"/var/log/apache2/dummy-project.example.com.error.log" {'
      end
      its(:content) { should include '  daily' }
      its(:content) { should include '  rotate 30' }
      its(:content) { should include '  missingok' }
      its(:content) { should include '  compress' }
      its(:content) { should include '  delaycompress' }
      its(:content) { should include '  notifempty' }
      its(:content) { should include '  copytruncate' }
      its(:content) { should include '  sharedscripts' }
    end

    describe file('/etc/apache2/ssl/dummy-project.example.com.key') do
      its(:content) { should include '-----BEGIN RSA PRIVATE KEY-----' }
    end

    describe file('/etc/apache2/ssl/dummy-project.example.com.crt') do
      its(:content) { should include '-----BEGIN CERTIFICATE-----' }
    end

    describe file('/etc/apache2/ssl/dummy-project.example.com.ca') do
      it { should_not exist }
    end

    describe file('/etc/apache2/ssl/dummy-project.example.com.dhparams.pem') do
      its(:content) { should include '-----BEGIN DH PARAMETERS-----' }
    end

    describe file('/etc/apache2/sites-enabled/dummy_project.conf') do
      it { should be_symlink }
    end

    describe file('/etc/apache2/sites-available/dummy_project.conf') do
      its(:content) { should include '<Proxy balancer://unicorn_dummy_project_example_com>' }
      its(:content) { should include 'SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH' }
      its(:content) { should include 'DocumentRoot /srv/www/dummy_project/current/public' }
      its(:content) do
        should include 'SSLOpenSSLConfCmd DHParameters "/etc/apache2/ssl/dummy-project.example.com.dhparams.pem"'
      end
      its(:content) { should include 'LimitRequestBody 134217728' }
      its(:content) { should include '# lorem ipsum dolor sit amet' }
    end
  end

  context 'appserver' do
    describe file('/srv/www/dummy_project/shared/config/unicorn.conf') do
      its(:content) { should include ':backlog => 2048' }
      its(:content) { should include ':tries => 10' }
      its(:content) { should include 'listen "127.0.0.1:3000"' }
    end

    describe file('/srv/www/dummy_project/shared/scripts/unicorn.service') do
      its(:content) { should include 'ENV[\'ENV_VAR1\'] = "test"' }
      its(:content) { should include 'ENV[\'HANAMI_ENV\'] = "production"' }
      its(:content) { should include 'ENV[\'HOME\'] = "/home/deploy"' }
      its(:content) { should include 'ENV[\'USER\'] = "deploy"' }
      its(:content) { should include 'PID_PATH="/run/lock/dummy_project/unicorn.pid"' }
    end
  end

  context 'framework' do
    describe file('/srv/www/dummy_project/shared/config/.env.production') do
      its(:content) { should include 'ENV_VAR1="test"' }
      its(:content) { should include 'ENV_VAR2="some data"' }
      its(:content) { should include 'HANAMI_ENV="production"' }
      its(:content) { should include 'DATABASE_URL="sqlite:///srv/www/dummy_project/shared/db/data.sqlite3"' }
    end
  end

  context 'worker' do
    describe file('/etc/monit/conf.d/resque_dummy_project.monitrc') do
      its(:content) { should include 'group resque_dummy_project_group' }
      its(:content) { should include 'check process resque_dummy_project-1' }
      its(:content) do
        should include 'HANAMI_ENV="production" DATABASE_URL="sqlite:///srv/www/dummy_project/shared/db/data.sqlite3"' \
                       ' HOME="/home/deploy" USER="deploy" QUEUE=default,mailers VERBOSE=1 ' \
                       'PIDFILE=/run/lock/dummy_project/' \
                       'resque_dummy_project-1.pid COUNT=3 bundle exec rake environment resque:work'
      end
      its(:content) { should include 'logger -t resque-dummy_project-1' }
      its(:content) { should include 'check process resque_dummy_project-2' }
      its(:content) do
        should include 'HANAMI_ENV="production" DATABASE_URL="sqlite:///srv/www/dummy_project/shared/db/data.sqlite3"' \
                       ' HOME="/home/deploy" USER="deploy" QUEUE=default,mailers VERBOSE=1 ' \
                       'PIDFILE=/run/lock/dummy_project/' \
                       'resque_dummy_project-2.pid COUNT=3 bundle exec rake environment resque:work'
      end
      its(:content) { should include 'logger -t resque-dummy_project-2' }
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
    describe service('apache2') do
      it { should be_running }
    end
  end

  context 'appserver' do
    describe command('pgrep -f unicorn | tr \'\n\' \' \'') do
      its(:stdout) { should match(/(?:[0-9]+ ){2}/) }
    end
  end

  context 'framework' do
    describe file('/srv/www/dummy_project/current/.env.production') do
      it { should be_symlink }
    end

    describe command('ls -1 /srv/www/dummy_project/current/public/assets/favicon-*.ico') do
      its(:stdout) { should match(/favicon-[0-9a-f]{32}.ico/) }
    end
  end
end
