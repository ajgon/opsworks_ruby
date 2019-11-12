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
    it { should_not be_installed }
  end

  describe file('/usr/local/bin/bundle') do
    it { should be_symlink }
  end
end

describe 'opsworks_ruby::configure' do
  context 'webserver' do
    context 'first installed app' do
      describe file('/etc/logrotate.d/other_project-apache2-production') do
        its(:owner) { should eq('root') }
        its(:group) { should eq('root') }
        its(:mode) { should eq('644') }
        its(:content) { should include '"/tmp/log1.log" "/tmp/log2.log"' }
        its(:content) { should include '  monthly' }
        its(:content) { should include '  rotate 15' }
        its(:content) { should include '  missingok' }
        its(:content) { should_not include '  compress' }
        its(:content) { should_not include '  delaycompress' }
        its(:content) { should include '  notifempty' }
        its(:content) { should_not include '  copytruncate' }
        its(:content) { should_not include '  sharedscripts' }
      end

      describe file('/etc/apache2/ssl/other-project.example.com.key') do
        its(:content) { should include '-----BEGIN RSA PRIVATE KEY-----' }
      end

      describe file('/etc/apache2/ssl/other-project.example.com.crt') do
        its(:content) { should include '-----BEGIN CERTIFICATE-----' }
      end

      describe file('/etc/apache2/ssl/other-project.example.com.ca') do
        it { should_not exist }
      end

      describe file('/etc/apache2/ssl/other-project.example.com.dhparams.pem') do
        it { should_not exist }
      end

      describe file('/etc/apache2/sites-enabled/other_project.conf') do
        it { should be_symlink }
      end

      %w[default default.conf 000-default 000-default.conf default-ssl default-ssl.conf].each do |file|
        describe file("/etc/apache2/sites-enabled/#{file}") do
          it { should_not exist }
        end
      end

      describe file('/etc/apache2/sites-available/other_project.conf') do
        its(:content) { should include 'SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH' }
        its(:content) { should include 'DocumentRoot /srv/www/other_project/current/public' }
        its(:content) { should_not include ' Proxy ' }
        its(:content) { should include '<Location /some/mount/point>' }
        its(:content) { should include 'PassengerAppEnv production' }
        its(:content) { should include 'PassengerBaseURI /some/mount/point' }
        its(:content) { should include 'PassengerMaxPoolSize 3' }
        its(:content) { should include 'PassengerMinInstances 2' }
        its(:content) { should include 'Listen 8080' }
        its(:content) { should include '<VirtualHost *:8080>' }
        its(:content) { should include 'Listen 8443' }
        its(:content) { should include '<VirtualHost *:8443>' }
      end
    end

    context 'second installed app' do
      describe file('/etc/logrotate.d/yet_another_project-apache2-production') do
        its(:owner) { should eq('deploy') }
        its(:group) { should eq('root') }
        its(:mode) { should eq('644') }
        its(:content) { should include '"/var/log/apache2/yet-another-project.example.com.access.log"' }
        its(:content) { should include '"/var/log/apache2/yet-another-project.example.com.error.log"' }
        its(:content) { should include '  daily' }
        its(:content) { should include '  rotate 75' }
        its(:content) { should include '  missingok' }
        its(:content) { should_not include '  compress' }
        its(:content) { should_not include '  delaycompress' }
        its(:content) { should include '  notifempty' }
        its(:content) { should include '  copytruncate' }
        its(:content) { should_not include '  sharedscripts' }
      end

      describe file('/etc/apache2/ssl/yet-another-project.example.com.key') do
        it { should_not exist }
      end

      describe file('/etc/apache2/ssl/yet-another-project.example.com.crt') do
        it { should_not exist }
      end

      describe file('/etc/apache2/ssl/yet-another-project.example.com.ca') do
        it { should_not exist }
      end

      describe file('/etc/apache2/ssl/yet-another-project.example.com.dhparams.pem') do
        it { should_not exist }
      end

      describe file('/etc/apache2/sites-enabled/yet_another_project.conf') do
        it { should be_symlink }
      end

      describe file('/etc/apache2/sites-available/yet_another_project.conf') do
        its(:content) { should_not include 'SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH' }
        its(:content) { should include '<Proxy balancer://unicorn_yet_another_project_example_com>' }
        its(:content) { should include 'DocumentRoot /srv/www/yet_another_project/current/public' }
        its(:content) { should include 'Listen 8081' }
        its(:content) { should include '<VirtualHost *:8081>' }
        its(:content) { should_not include '<VirtualHost *:844' }
      end
    end
  end

  context 'appserver' do
    context 'first installed app' do
      describe file('/srv/www/other_project/shared/config/unicorn.conf') do
        it { should_not exist }
      end

      describe file('/srv/www/other_project/shared/scripts/unicorn.service') do
        it { should_not exist }
      end
    end

    context 'second installed app' do
      describe file('/srv/www/yet_another_project/shared/config/unicorn.conf') do
        its(:content) { should include ':backlog => 1024' }
        its(:content) { should include ':tries => 5' }
        its(:content) { should include 'listen "127.0.0.1:3000"' }
      end

      describe file('/srv/www/yet_another_project/shared/scripts/unicorn.service') do
        its(:content) { should include 'ENV[\'ENV_VAR1\'] = "test"' }
        its(:content) { should include 'ENV[\'RAILS_ENV\'] = "production"' }
        its(:content) { should include 'ENV[\'HOME\'] = "/home/deploy"' }
        its(:content) { should include 'ENV[\'USER\'] = "deploy"' }
        its(:content) { should include 'PID_PATH="/run/lock/yet_another_project/unicorn.pid"' }
      end
    end
  end

  context 'framework' do
    context 'first installed app' do
      describe file('/etc/logrotate.d/other_project-rails-production') do
        it { should_not exist }
      end

      describe file('/etc/logrotate.d/dumber-app-logrotate') do
        its(:owner) { should eq('deploy') }
        its(:group) { should eq('www-data') }
        its(:mode) { should eq('750') }
        its(:content) { should include '"/srv/www/other_project/shared/log/*.log" {' }
        its(:content) { should include '  weekly' }
        its(:content) { should include '  rotate 75' }
        its(:content) { should include '  missingok' }
        its(:content) { should_not include '  compress' }
        its(:content) { should_not include '  delaycompress' }
        its(:content) { should include '  notifempty' }
        its(:content) { should include '  copytruncate' }
        its(:content) { should include '  sharedscripts' }
      end

      describe file('/srv/www/other_project/shared/config/.env.production') do
        it { should_not exist }
      end
    end

    context 'second installed app' do
      describe file('/etc/logrotate.d/yet_another_project-rails-production') do
        it { should_not exist }
      end

      describe file('/etc/logrotate.d/dumberer-app-logrotate') do
        its(:owner) { should eq('deploy') }
        its(:group) { should eq('www-data') }
        its(:mode) { should eq('644') }
        its(:content) { should include '"/srv/www/yet_another_project/shared/log/*.log" {' }
        its(:content) { should include '  daily' }
        its(:content) { should include '  rotate 75' }
        its(:content) { should include '  missingok' }
        its(:content) { should_not include '  compress' }
        its(:content) { should_not include '  delaycompress' }
        its(:content) { should include '  notifempty' }
        its(:content) { should include '  copytruncate' }
        its(:content) { should include '  sharedscripts' }
      end

      describe file('/srv/www/other_project/shared/config/.env.production') do
        it { should_not exist }
      end
    end
  end
end

describe 'opsworks_ruby::deploy' do
  context 'source' do
    describe file('/tmp/ssh-git-wrapper.sh') do
      it { should_not exist }
    end

    describe file('/var/tmp/my-generated-ssh-wrapper.sh') do
      its(:content) { should include 'exec ssh -o UserKnownHostsFile=/dev/null' }
    end

    describe file('/srv/www/other_project/current/.git') do
      it { should_not exist }
    end

    describe file('/srv/www/yet_another_project/current/.git') do
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
    describe file('/srv/www/other_project/shared/config/database.yml') do
      its(:content) { should include 'primary:' }
      its(:content) { should include 'secondary:' }
      its(:content) { should include 'adapter: sqlite3' }
    end

    describe file('/srv/www/yet_another_project/current/config/database.yml') do
      it { should be_symlink }
    end
  end
end
