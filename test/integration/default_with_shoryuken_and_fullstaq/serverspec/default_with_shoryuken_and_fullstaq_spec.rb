# frozen_string_literal: true

require 'spec_helper'

describe 'opsworks_ruby::setup' do
  describe package('fullstaq-ruby-2.6-jemalloc') do
    it { should be_installed }
  end

  describe package('libsqlite3-dev') do
    it { should be_installed }
  end

  describe package('git') do
    it { should be_installed }
  end

  describe package('gnupg2') do
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

  describe file('/etc/environment') do
    its(:content) do
      should include 'PATH="/usr/lib/fullstaq-ruby/versions/2.6-jemalloc/bin'
    end
  end
end

describe 'opsworks_ruby::configure' do
  context 'webserver' do
    describe file('/etc/logrotate.d/dummy_project-nginx-production') do
      its(:content) do
        should include '"/var/log/nginx/dummy-project.example.com.access.log" ' \
                       '"/var/log/nginx/dummy-project.example.com.error.log" {'
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
      its(:content) { should include 'ENV[\'HOME\'] = "/home/deploy"' }
      its(:content) { should include 'ENV[\'USER\'] = "deploy"' }
      its(:content) { should include 'PID_PATH="/run/lock/dummy_project/puma.pid"' }
    end
  end

  context 'framework' do
    describe file('/etc/logrotate.d/dummy_project-rails-production') do
      its(:content) { should include '"/srv/www/dummy_project/shared/log/*.log" {' }
      its(:content) { should include '  daily' }
      its(:content) { should include '  rotate 30' }
      its(:content) { should include '  missingok' }
      its(:content) { should include '  compress' }
      its(:content) { should include '  delaycompress' }
      its(:content) { should include '  notifempty' }
      its(:content) { should include '  copytruncate' }
      its(:content) { should include '  sharedscripts' }
    end

    describe file('/srv/www/dummy_project/current/config/database.yml') do
      its(:content) { should include 'adapter: sqlite3' }
    end
  end

  context 'worker' do
    describe file('/srv/www/dummy_project/shared/config/shoryuken_dummy_project-1.yml') do
      its(:content) { should include 'concurrency: 6' }
      its(:content) { should include 'verbose: true' }
      its(:content) { should_not include 'queues:' }
    end

    describe file('/etc/monit/conf.d/shoryuken_dummy_project.monitrc') do
      its(:content) do
        should include 'bundle exec shoryuken -C /srv/www/dummy_project/shared/config/shoryuken_dummy_project-1.yml ' \
                        '-P /run/lock/shoryuken_dummy_project-1.pid -R'
      end
      its(:content) { should include 'kill -s TERM $(cat /run/lock/shoryuken_dummy_project-1.pid)' }
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
      its(:stdout) { should match(/(?:[0-9]+ ){2,4}/) }
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

  context 'worker' do
    describe command('pgrep -f shoryuken') do
      its(:stdout) { should match(/(?:[0-9]+)/) }
    end
  end
end
