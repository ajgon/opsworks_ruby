# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength
require 'spec_helper'

describe 'opsworks_ruby::setup' do
  describe package('ruby2.3') do
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

  describe package('zlib1g-dev') do
    it { should be_installed }
  end

  describe package('monit') do
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
    describe file('/etc/nginx/ssl/dummy-project.example.com.key') do
      its(:content) { should include '--- SSL PRIVATE KEY ---' }
    end

    describe file('/etc/nginx/ssl/dummy-project.example.com.crt') do
      its(:content) { should include '--- SSL CERTIFICATE ---' }
    end

    describe file('/etc/nginx/ssl/dummy-project.example.com.ca') do
      its(:content) { should include '--- SSL CERTIFICATE CHAIN ---' }
    end

    describe file('/etc/nginx/ssl/dummy-project.example.com.dhparams.pem') do
      its(:content) { should include '--- DH PARAMS ---' }
    end

    describe file('/etc/nginx/sites-enabled/dummy_project.conf') do
      it { should be_symlink }
    end

    describe file('/etc/nginx/sites-available/dummy_project.conf') do
      its(:content) { should include 'upstream puma_dummy-project.example.com' }
      its(:content) do
        should include 'ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH:ECDHE-RSA-AES128-GCM-SHA384:' \
                       'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA128:DHE-RSA-AES128-GCM-SHA384:' \
                       'DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-GCM-SHA128:ECDHE-RSA-AES128-SHA384:' \
                       'ECDHE-RSA-AES128-SHA128:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA128:' \
                       'DHE-RSA-AES128-SHA128:DHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:' \
                       'EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA384:AES128-GCM-SHA128:AES128-SHA128:AES128-SHA128:' \
                       'AES128-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";'
      end
      its(:content) { should include 'root /srv/www/dummy_project/current/public;' }
      its(:content) { should include 'client_max_body_size 128m;' }
      its(:content) { should include 'location /ok { return 201; }' }
    end
  end

  context 'appserver' do
    describe file('/srv/www/dummy_project/shared/config/puma.rb') do
      its(:content) { should include 'workers 10' }
      its(:content) { should include 'unix:///srv/www/dummy_project/shared/sockets/puma.sock' }
      its(:content) { should include 'environment "staging"' }
      its(:content) { should include 'worker_timeout 120' }
      its(:content) { should_not include 'quiet' }
    end

    describe file('/srv/www/dummy_project/shared/scripts/puma.service') do
      its(:content) { should include 'ENV[\'ENV_VAR1\'] = "test"' }
      its(:content) { should include 'ENV[\'RAILS_ENV\'] = "staging"' }
      its(:content) { should include 'PID_PATH="/srv/www/dummy_project/shared/pids/puma.pid"' }
      its(:content) { should include 'def puma_running?' }
    end
  end

  context 'framework' do
    describe file('/srv/www/dummy_project/current/config/database.yml') do
      its(:content) { should include 'adapter: sqlite3' }
      its(:content) { should include 'reaping_frequency: 10' }
    end
  end

  context 'worker' do
    describe file('/srv/www/dummy_project/shared/config/sidekiq_1.yml') do
      its(:content) { should include ':concurency: 5' }
      its(:content) { should include ':verbose: true' }
      its(:content) { should include ':queues:' }
      its(:content) { should include '- default' }
      its(:content) { should include '- mailers' }
    end

    describe file('/srv/www/dummy_project/shared/config/sidekiq_2.yml') do
      its(:content) { should include ':concurency: 5' }
      its(:content) { should include ':verbose: true' }
      its(:content) { should include ':queues:' }
      its(:content) { should include '- default' }
      its(:content) { should include '- mailers' }
    end

    describe file('/etc/monit/conf.d/sidekiq_dummy_project.monitrc') do
      its(:content) { should include 'group sidekiq_dummy_project_group' }
      its(:content) { should include 'check process sidekiq_dummy_project-1' }
      its(:content) do
        should include 'RAILS_ENV="staging" bundle exec sidekiq -C /srv/www/dummy_project/shared/config/sidekiq_1.yml'
      end
      its(:content) { should include 'logger -t sidekiq-dummy_project-1' }
      its(:content) { should include 'check process sidekiq_dummy_project-2' }
      its(:content) do
        should include 'RAILS_ENV="staging" bundle exec sidekiq -C /srv/www/dummy_project/shared/config/sidekiq_2.yml'
      end
      its(:content) { should include 'logger -t sidekiq-dummy_project-2' }
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

    describe file('/srv/www/dummy_project/shared/config/application.yml') do
      its(:content) { should include 'ENV_VAR1: "test"' }
      its(:content) { should include 'ENV_VAR2: "some data"' }
      its(:content) { should include 'RAILS_ENV: "staging"' }
    end

    describe file('/srv/www/dummy_project/shared/dot_env') do
      its(:content) { should include 'ENV_VAR1="test"' }
      its(:content) { should include 'ENV_VAR2="some data"' }
      its(:content) { should include 'RAILS_ENV="staging"' }
    end

    describe file('/srv/www/dummy_project/current/.env') do
      it { should be_symlink }
    end

    describe file('/srv/www/dummy_project/current/config/application.yml') do
      it { should be_symlink }
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

    describe file('/srv/www/dummy_project/current/config/application.rb') do
      its(:content) { should include 'if(defined?(Rails::Console))' }
      its(:content) { should include 'ENV[\'ENV_VAR1\'] = "test"' }
      its(:content) { should include 'ENV[\'ENV_VAR2\'] = "some data"' }
      its(:content) { should include 'ENV[\'RAILS_ENV\'] = "staging"' }
    end
  end
end
# rubocop:enable Metrics/BlockLength
