# frozen_string_literal: true

#
# Cookbook Name:: opsworks_ruby
# Spec:: configure
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'opsworks_ruby::configure' do
  let(:chef_runner) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
      solo_node.set['deploy'] = node['deploy']
      solo_node.set['nginx'] = node['nginx']
    end
  end
  let(:chef_run) do
    chef_runner.converge(described_recipe)
  end
  let(:chef_runner_rhel) do
    ChefSpec::SoloRunner.new(platform: 'amazon', version: '2016.03') do |solo_node|
      solo_node.set['deploy'] = node['deploy']
    end
  end
  let(:chef_run_rhel) do
    chef_runner_rhel.converge(described_recipe)
  end
  before do
    stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app])
    stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([aws_opsworks_rds_db_instance])
  end

  context 'context savvy' do
    it 'creates shared' do
      expect(chef_run).to create_directory("/srv/www/#{aws_opsworks_app['shortname']}/shared")
    end

    it 'creates shared/config' do
      expect(chef_run).to create_directory("/srv/www/#{aws_opsworks_app['shortname']}/shared/config")
    end

    it 'creates shared/log' do
      expect(chef_run).to create_directory("/srv/www/#{aws_opsworks_app['shortname']}/shared/log")
    end

    it 'creates shared/scripts' do
      expect(chef_run).to create_directory("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts")
    end

    it 'creates shared/sockets' do
      expect(chef_run).to create_directory("/srv/www/#{aws_opsworks_app['shortname']}/shared/sockets")
    end

    it 'creates shared/vendor/bundle' do
      expect(chef_run).to create_directory("/srv/www/#{aws_opsworks_app['shortname']}/shared/vendor/bundle")
    end

    it 'creates /run/lock/dummy_project' do
      expect(chef_run).to create_directory("/run/lock/#{aws_opsworks_app['shortname']}")
    end

    it 'links shared/pids to /run/lock/dummy_project' do
      expect(chef_run).to create_link("/srv/www/#{aws_opsworks_app['shortname']}/shared/pids")
        .with(to: "/run/lock/#{aws_opsworks_app['shortname']}")
    end
  end

  context 'Postgresql + Git + Unicorn + Nginx + Rails + Sidekiq' do
    it 'creates proper database.yml template' do
      db_config = Drivers::Db::Postgresql.new(chef_run, aws_opsworks_app, rds: aws_opsworks_rds_db_instance).out
      expect(db_config[:adapter]).to eq 'postgresql'
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/database.yml").with_content(
          JSON.parse({ development: db_config, production: db_config, staging: db_config }.to_json).to_yaml
        )
    end

    it 'creates logrotate file for rails' do
      expect(chef_run)
        .to enable_logrotate_app("#{aws_opsworks_app['shortname']}-rails-staging")
    end

    it 'creates logrotate file for nginx' do
      expect(chef_run)
        .to enable_logrotate_app("#{aws_opsworks_app['shortname']}-nginx-staging")
    end

    it 'deletes default logrotate file for nginx' do
      expect(chef_run).to disable_logrotate_app('nginx')
    end

    context 'when the logrotate settings are overridden by attributes at various levels of precedence' do
      let(:logrotate_paths) { %w[/some/path/to/a.log] }
      let(:chef_runner) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
          solo_node.set['defaults']['global']['logrotate_cookbook']          = 'default_global_cookbook'
          solo_node.set['defaults']['global']['logrotate_template_name']     = 'default_global_template.erb'
          solo_node.set['defaults']['global']['logrotate_template_owner']    = 'me'
          solo_node.set['defaults']['global']['logrotate_template_group']    = 'a_group'
          solo_node.set['defaults']['global']['logrotate_template_mode']     = '0700'
          solo_node.set['defaults']['global']['logrotate_options']           = %w[a b c d]
          solo_node.set['defaults']['framework']['logrotate_rotate']         = 60
          solo_node.set['defaults']['framework']['logrotate_template_name']  = 'some_template.erb'

          app_name = aws_opsworks_app['shortname']
          solo_node.set['deploy'][app_name]['global']['logrotate_name']              = 'app_global_name'
          solo_node.set['deploy'][app_name]['global']['logrotate_cookbook']          = 'app_global_cookbook'
          solo_node.set['deploy'][app_name]['global']['logrotate_rotate']            = 45
          solo_node.set['deploy'][app_name]['global']['logrotate_template_mode']     = '0750'
          solo_node.set['deploy'][app_name]['framework']['logrotate_name']           = 'myapp'
          solo_node.set['deploy'][app_name]['framework']['logrotate_cookbook']       = 'other_cookbook'
          solo_node.set['deploy'][app_name]['framework']['logrotate_log_paths']      = logrotate_paths
          solo_node.set['deploy'][app_name]['framework']['logrotate_frequency']      = 'weekly'
          solo_node.set['deploy'][app_name]['framework']['logrotate_rotate']         = 15
          solo_node.set['deploy'][app_name]['framework']['logrotate_template_owner'] = 'you'
          solo_node.set['deploy'][app_name]['framework']['logrotate_template_mode']  = '0755'
          solo_node.set['deploy'][app_name]['framework']['logrotate_options']        = %w[g h i j]

          solo_node.set['nginx'] = node['nginx']
        end
      end

      it 'configures logrotate for the app framework using the provided framework and global settings' do
        expect(chef_run)
          .to enable_logrotate_app('myapp')
          .with_path(logrotate_paths)
          .with_rotate(15)
          .with_cookbook('other_cookbook')
          .with_template_name('some_template.erb')
          .with_template_owner('you')
          .with_template_group('a_group')
          .with_template_mode('0755')
          .with_frequency('weekly')
          .with_options(%w[g h i j])
      end

      it 'configures logrotate for the app webserver using the provided global settings only' do
        expect(chef_run)
          .to enable_logrotate_app("#{aws_opsworks_app['shortname']}-nginx-production")
          .with_path(%w[
                       /var/log/nginx/dummy-project.example.com.access.log
                       /var/log/nginx/dummy-project.example.com.error.log
                     ])
          .with_rotate(45)
          .with_template_name('default_global_template.erb')
          .with_cookbook('app_global_cookbook')
          .with_template_owner('me')
          .with_template_group('a_group')
          .with_template_mode('0750')
      end

      context 'when the set of logrotate paths empty' do
        let(:logrotate_paths) { [] }

        it 'does not create any logrotate file' do
          expect(chef_run).not_to enable_logrotate_app('myapp')
        end
      end
    end

    it 'creates proper unicorn.conf file' do
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/unicorn.conf")
        .with_content("listen \"/srv/www/#{aws_opsworks_app['shortname']}/shared/sockets/unicorn.sock\",")
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/unicorn.conf")
        .with_content('worker_processes 4')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/unicorn.conf")
        .with_content(':delay => 3')
    end

    it 'creates proper unicorn.service file' do
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/unicorn.service")
        .with_content('ENV[\'RAILS_ENV\'] = "staging"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/unicorn.service")
        .with_content('ENV[\'ENV_VAR1\'] = "test"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/unicorn.service")
        .with_content('ENV[\'HOME\'] = "/home/deploy"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/unicorn.service")
        .with_content('ENV[\'USER\'] = "deploy"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/unicorn.service")
        .with_content("APP_NAME=\"#{aws_opsworks_app['shortname']}\"")
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/unicorn.service")
        .with_content("ROOT_PATH=\"/srv/www/#{aws_opsworks_app['shortname']}\"")
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/unicorn.service")
        .with_content('DEPLOY_ENV="staging"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/unicorn.service")
        .with_content('unicorn_rails --env #\{DEPLOY_ENV\} --daemonize -c #\{ROOT_PATH\}/shared/config/unicorn.conf')
    end

    it 'defines unicorn service' do
      service = chef_run.service("unicorn_#{aws_opsworks_app['shortname']}")
      expect(service).to do_nothing
      expect(service.start_command)
        .to eq "/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/unicorn.service start"
      expect(service.stop_command)
        .to eq "/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/unicorn.service stop"
      expect(service.restart_command)
        .to eq "/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/unicorn.service restart"
      expect(service.status_command)
        .to eq "/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/unicorn.service status"
    end

    it 'creates nginx unicorn proxy handler config' do
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('listen 80;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('listen 443;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('proxy_hide_header X-Powered-By;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('error_log /var/log/nginx/dummy-project.example.com-ssl.error.log debug;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('upstream unicorn_dummy-project.example.com {')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('client_max_body_size 125m;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('client_body_timeout 30;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('keepalive_timeout 65;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ssl_certificate_key /etc/nginx/ssl/dummy-project.example.com.key;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ssl_dhparam /etc/nginx/ssl/dummy-project.example.com.dhparams.pem;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ssl_ecdh_curve secp384r1;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ssl_stapling on;')
      expect(chef_run)
        .not_to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ssl_session_tickets off;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('extra_config {}')
      expect(chef_run)
        .not_to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('extra_config_ssl {}')
      expect(chef_run)
        .not_to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('upgrade')
      expect(chef_run).to create_link("/etc/nginx/sites-enabled/#{aws_opsworks_app['shortname']}.conf")
    end

    it 'enables ssl rules for legacy browsers in nginx config' do
      chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy[aws_opsworks_app['shortname']]['webserver']['ssl_for_legacy_browsers'] = true
        solo_node.set['deploy'] = deploy
        solo_node.set['nginx'] = node['nginx']
      end.converge(described_recipe)
      expect(chef_run).to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf").with_content(
        'ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH:ECDHE-RSA-AES128-GCM-SHA384:' \
        'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA128:DHE-RSA-AES128-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:' \
        'DHE-RSA-AES128-GCM-SHA128:ECDHE-RSA-AES128-SHA384:ECDHE-RSA-AES128-SHA128:ECDHE-RSA-AES128-SHA:' \
        'ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA128:DHE-RSA-AES128-SHA128:DHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA:' \
        'ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA384:AES128-GCM-SHA128:AES128-SHA128:AES128-SHA128:' \
        'AES128-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";'
      )
      expect(chef_run)
        .not_to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ssl_ecdh_curve secp384r1;')
    end

    it 'creates SSL keys for nginx' do
      expect(chef_run).to create_directory('/etc/nginx/ssl')
      expect(chef_run)
        .to render_file("/etc/nginx/ssl/#{aws_opsworks_app['domains'].first}.key")
        .with_content('--- SSL PRIVATE KEY ---')
      expect(chef_run)
        .to render_file("/etc/nginx/ssl/#{aws_opsworks_app['domains'].first}.crt")
        .with_content('--- SSL CERTIFICATE ---')
      expect(chef_run)
        .to render_file("/etc/nginx/ssl/#{aws_opsworks_app['domains'].first}.ca")
        .with_content('--- SSL CERTIFICATE CHAIN ---')
      expect(chef_run)
        .to render_file("/etc/nginx/ssl/#{aws_opsworks_app['domains'].first}.dhparams.pem")
        .with_content('--- DH PARAMS ---')
    end

    it 'enables upgrade method in nginx config' do
      chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy[aws_opsworks_app['shortname']]['webserver']['enable_upgrade_method'] = true
        solo_node.set['deploy'] = deploy
        solo_node.set['nginx'] = node['nginx']
      end.converge(described_recipe)
      expect(chef_run).to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf").with_content(
        'proxy_set_header Upgrade $http_upgrade;'
      )
    end

    it 'creates sidekiq.conf.yml' do
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/sidekiq_1.yml")
        .with_content("---\n:concurrency: 5\n:verbose: false\n:queues:\n- default")
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/sidekiq_2.yml")
        .with_content("---\n:concurrency: 5\n:verbose: false\n:queues:\n- default")
    end

    it 'allows overriding of ports' do
      chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy[aws_opsworks_app['shortname']]['webserver']['port'] = 8080
        deploy[aws_opsworks_app['shortname']]['webserver']['ssl_port'] = 8443
        solo_node.set['deploy'] = deploy
        solo_node.set['nginx'] = node['nginx']
      end.converge(described_recipe)
      expect(chef_run).to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf").with_content(
        'listen 8080;'
      )
      expect(chef_run).to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf").with_content(
        'listen 8443;'
      )
    end

    it 'allows choosing a different template, from a different cookbook' do
      chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy[aws_opsworks_app['shortname']]['webserver']['site_config_template'] = 'appserver.test.conf.erb'
        deploy[aws_opsworks_app['shortname']]['webserver']['site_config_template_cookbook'] = 'some_cookbook'
        solo_node.set['deploy'] = deploy
        solo_node.set['nginx'] = node['nginx']
      end.converge(described_recipe)
      expect(chef_run).to create_template("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_source('appserver.test.conf.erb')
        .with_cookbook('some_cookbook')
    end

    context 'rhel' do
      it 'creates sidekiq.monitrc conf' do
        expect(chef_run_rhel).to create_template("/etc/monit.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('check process sidekiq_dummy_project-1')
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('with pidfile /run/lock/dummy_project/sidekiq_dummy_project-1.pid')
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'start program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
            'ENV_VAR2="some data" RAILS_ENV="staging" HOME="/home/deploy" USER="deploy" bundle exec sidekiq ' \
            '-C /srv/www/dummy_project/shared/config/sidekiq_1.yml ' \
            '-i 0 ' \
            '-P /run/lock/dummy_project/sidekiq_dummy_project-1.pid ' \
            '-r /srv/www/dummy_project/current/lorem_ipsum.rb 2>&1 ' \
            '| logger -t sidekiq-dummy_project-1\'" with timeout 90 seconds'
          )
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'stop program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
            'ENV_VAR2="some data" RAILS_ENV="staging" HOME="/home/deploy" USER="deploy" bundle exec sidekiqctl stop ' \
            '/run/lock/dummy_project/sidekiq_dummy_project-1.pid 8\'" with timeout 18 seconds'
          )
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('check process sidekiq_dummy_project-2')
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('with pidfile /run/lock/dummy_project/sidekiq_dummy_project-2.pid')
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'start program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
            'ENV_VAR2="some data" RAILS_ENV="staging" HOME="/home/deploy" USER="deploy" bundle exec sidekiq ' \
            '-C /srv/www/dummy_project/shared/config/sidekiq_2.yml ' \
            '-i 1 ' \
            '-P /run/lock/dummy_project/sidekiq_dummy_project-2.pid ' \
            '-r /srv/www/dummy_project/current/lorem_ipsum.rb 2>&1 ' \
            '| logger -t sidekiq-dummy_project-2\'" with timeout 90 seconds'
          )
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'stop program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
            'ENV_VAR2="some data" RAILS_ENV="staging" HOME="/home/deploy" USER="deploy" bundle exec sidekiqctl stop ' \
            '/run/lock/dummy_project/sidekiq_dummy_project-2.pid 8\'" with timeout 18 seconds'
          )
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('group sidekiq_dummy_project_group')
        expect(chef_run_rhel).to run_execute('monit reload')
      end
    end

    context 'debian' do
      it 'creates sidekiq.monitrc conf' do
        expect(chef_run).to create_template("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
        expect(chef_run)
          .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('check process sidekiq_dummy_project-1')
        expect(chef_run)
          .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('with pidfile /run/lock/dummy_project/sidekiq_dummy_project-1.pid')
        expect(chef_run)
          .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'start program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
            'ENV_VAR2="some data" RAILS_ENV="staging" HOME="/home/deploy" USER="deploy" bundle exec sidekiq ' \
            '-C /srv/www/dummy_project/shared/config/sidekiq_1.yml ' \
            '-i 0 ' \
            '-P /run/lock/dummy_project/sidekiq_dummy_project-1.pid ' \
            '-r /srv/www/dummy_project/current/lorem_ipsum.rb 2>&1 ' \
            '| logger -t sidekiq-dummy_project-1\'" with timeout 90 seconds'
          )
        expect(chef_run)
          .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'stop program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
            'ENV_VAR2="some data" RAILS_ENV="staging" HOME="/home/deploy" USER="deploy" bundle exec sidekiqctl stop ' \
            '/run/lock/dummy_project/sidekiq_dummy_project-1.pid 8\'" with timeout 18 seconds'
          )
        expect(chef_run)
          .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('check process sidekiq_dummy_project-2')
        expect(chef_run)
          .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('with pidfile /run/lock/dummy_project/sidekiq_dummy_project-2.pid')
        expect(chef_run)
          .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'start program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
            'ENV_VAR2="some data" RAILS_ENV="staging" HOME="/home/deploy" USER="deploy" bundle exec sidekiq ' \
            '-C /srv/www/dummy_project/shared/config/sidekiq_2.yml ' \
            '-i 1 ' \
            '-P /run/lock/dummy_project/sidekiq_dummy_project-2.pid ' \
            '-r /srv/www/dummy_project/current/lorem_ipsum.rb 2>&1 ' \
            '| logger -t sidekiq-dummy_project-2\'" with timeout 90 seconds'
          )
        expect(chef_run)
          .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'stop program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
            'ENV_VAR2="some data" RAILS_ENV="staging" HOME="/home/deploy" USER="deploy" bundle exec sidekiqctl stop ' \
            '/run/lock/dummy_project/sidekiq_dummy_project-2.pid 8\'" with timeout 18 seconds'
          )
        expect(chef_run)
          .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('group sidekiq_dummy_project_group')
        expect(chef_run).to run_execute('monit reload')
      end
    end
  end

  context 'Mysql + Puma + Apache2 + hanami.rb + resque' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy['dummy_project']['appserver']['adapter'] = 'puma'
        deploy['dummy_project']['webserver']['adapter'] = 'apache2'
        deploy['dummy_project']['webserver']['keepalive_timeout'] = '65'
        deploy['dummy_project']['framework']['adapter'] = 'hanami'
        deploy['dummy_project']['worker']['adapter'] = 'resque'
        solo_node.set['deploy'] = deploy
      end.converge(described_recipe)
    end

    before do
      stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([aws_opsworks_rds_db_instance(engine: 'mysql')])
    end

    it 'creates logrotate file for apache2' do
      expect(chef_run)
        .to enable_logrotate_app("#{aws_opsworks_app['shortname']}-apache2-staging")
    end

    it 'deletes default logrotate file for apache2' do
      expect(chef_run).to disable_logrotate_app('apache2')
    end

    it 'creates proper .env.*' do
      db_config =
        Drivers::Db::Mysql.new(chef_run, aws_opsworks_app, rds: aws_opsworks_rds_db_instance(engine: 'mysql')).out
      expect(db_config[:adapter]).to eq 'mysql2'

      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/.env.staging")
        .with_content('ENV_VAR1="test"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/.env.staging")
        .with_content('ENV_VAR2="some data"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/.env.staging")
        .with_content('HANAMI_ENV="staging"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/.env.staging")
        .with_content(
          "DATABASE_URL=\"mysql2://dbuser:#{db_config[:password]}@" \
          'dummy-project.c298jfowejf.us-west-2.rds.amazon.com:3265/dummydb"'
        )
    end

    it 'creates proper puma.rb file' do
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/puma.rb")
        .with_content('workers 4')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/puma.rb")
        .with_content('bind "tcp://127.0.0.1:3000"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/puma.rb")
        .with_content('environment "staging"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/puma.rb")
        .with_content('threads 0, 16')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/puma.rb")
        .with_content('worker_timeout 60')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/puma.rb")
        .with_content('plugin :tmp_restart')
    end

    it 'creates proper puma.service file' do
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/puma.service")
        .with_content('ENV[\'HANAMI_ENV\'] = "staging"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/puma.service")
        .with_content('ENV[\'ENV_VAR1\'] = "test"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/puma.service")
        .with_content('ENV[\'HOME\'] = "/home/deploy"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/puma.service")
        .with_content('ENV[\'USER\'] = "deploy"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/puma.service")
        .with_content(
          'ENV[\'DATABASE_URL\'] = "mysql2://dbuser:03c1bc98cdd5eb2f9c75@' \
          'dummy-project.c298jfowejf.us-west-2.rds.amazon.com:3265/dummydb"'
        )
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/puma.service")
        .with_content("APP_NAME=\"#{aws_opsworks_app['shortname']}\"")
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/puma.service")
        .with_content("ROOT_PATH=\"/srv/www/#{aws_opsworks_app['shortname']}\"")
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/puma.service")
        .with_content('DEPLOY_ENV="staging"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/puma.service")
        .with_content('puma -C #\{ROOT_PATH\}/shared/config/puma.rb')
    end

    it 'defines puma service' do
      service = chef_run.service("puma_#{aws_opsworks_app['shortname']}")
      expect(service).to do_nothing
      expect(service.start_command)
        .to eq "/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/puma.service start"
      expect(service.stop_command)
        .to eq "/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/puma.service stop"
      expect(service.restart_command)
        .to eq "/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/puma.service restart"
      expect(service.status_command)
        .to eq "/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/puma.service status"
    end

    it 'creates apache2 puma proxy handler config' do
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('<Proxy balancer://puma_dummy_project_example_com>')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('LogLevel debug')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('LimitRequestBody 131072000')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('KeepAliveTimeout 65')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('SSLCertificateKeyFile /etc/apache2/ssl/dummy-project.example.com.key')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('SSLOpenSSLConfCmd DHParameters "/etc/apache2/ssl/dummy-project.example.com.dhparams.pem"')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('SSLUseStapling on')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('extra_config {}')
      expect(chef_run)
        .not_to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('extra_config_ssl {}')
      expect(chef_run)
        .not_to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content(/^Listen/)
      expect(chef_run).to create_link("/etc/apache2/sites-enabled/#{aws_opsworks_app['shortname']}.conf")
    end

    it 'enables ssl rules for legacy browsers in apache2 config' do
      chefrun = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy[aws_opsworks_app['shortname']]['webserver']['adapter'] = 'apache2'
        deploy[aws_opsworks_app['shortname']]['webserver']['ssl_for_legacy_browsers'] = true
        solo_node.set['deploy'] = deploy
      end.converge(described_recipe)

      expect(chefrun).to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf").with_content(
        'SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH:ECDHE-RSA-AES128-GCM-SHA384:' \
        'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA128:DHE-RSA-AES128-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:' \
        'DHE-RSA-AES128-GCM-SHA128:ECDHE-RSA-AES128-SHA384:ECDHE-RSA-AES128-SHA128:ECDHE-RSA-AES128-SHA:' \
        'ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA128:DHE-RSA-AES128-SHA128:DHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA:' \
        'ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA384:AES128-GCM-SHA128:AES128-SHA128:AES128-SHA128:' \
        'AES128-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4'
      )
    end

    it 'creates SSL keys for apache2' do
      expect(chef_run).to create_directory('/etc/apache2/ssl')
      expect(chef_run)
        .to render_file("/etc/apache2/ssl/#{aws_opsworks_app['domains'].first}.key")
        .with_content('--- SSL PRIVATE KEY ---')
      expect(chef_run)
        .to render_file("/etc/apache2/ssl/#{aws_opsworks_app['domains'].first}.crt")
        .with_content('--- SSL CERTIFICATE ---')
      expect(chef_run)
        .to render_file("/etc/apache2/ssl/#{aws_opsworks_app['domains'].first}.ca")
        .with_content('--- SSL CERTIFICATE CHAIN ---')
      expect(chef_run)
        .to render_file("/etc/apache2/ssl/#{aws_opsworks_app['domains'].first}.dhparams.pem")
        .with_content('--- DH PARAMS ---')
    end

    it 'allows overriding of ports' do
      chefrun = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy[aws_opsworks_app['shortname']]['webserver']['adapter'] = 'apache2'
        deploy[aws_opsworks_app['shortname']]['webserver']['port'] = 8080
        deploy[aws_opsworks_app['shortname']]['webserver']['ssl_port'] = 8443
        solo_node.set['deploy'] = deploy
      end.converge(described_recipe)

      expect(chefrun).to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf").with_content(
        '<VirtualHost *:8080>'
      )
      expect(chefrun).to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf").with_content(
        'Listen 8080'
      )
      expect(chefrun).to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf").with_content(
        '<VirtualHost *:8443>'
      )
      expect(chefrun).to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf").with_content(
        'Listen 8443'
      )
    end

    it 'cleans default sites' do
      %w[default default.conf 000-default 000-default.conf default-ssl default-ssl.conf].each do |file|
        expect(chef_run).to delete_file("/etc/apache2/sites-enabled/#{file}")
      end
    end

    it 'creates resque.monitrc conf' do
      expect(chef_run).to create_template("/etc/monit/conf.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('check process resque_dummy_project-1')
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('with pidfile /run/lock/dummy_project/resque_dummy_project-1.pid')
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content(
          'start program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
          'ENV_VAR2="some data" HANAMI_ENV="staging" DATABASE_URL="mysql2://dbuser:03c1bc98cdd5eb2f9c75@' \
          'dummy-project.c298jfowejf.us-west-2.rds.amazon.com:3265/dummydb" HOME="/home/deploy" USER="deploy" ' \
          'QUEUE=test_queue VERBOSE=1 PIDFILE=/run/lock/dummy_project/resque_dummy_project-1.pid COUNT=2 ' \
          'bundle exec rake environment resque:work 2>&1 | logger -t resque-dummy_project-1\'" ' \
          'with timeout 90 seconds'
        )
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content(
          'stop  program = "/bin/su - deploy -c ' \
          '\'kill -s TERM `cat /run/lock/dummy_project/resque_dummy_project-1.pid`\'' \
          '" with timeout 90 seconds'
        )
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('check process resque_dummy_project-2')
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('with pidfile /run/lock/dummy_project/resque_dummy_project-2.pid')
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content(
          'start program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
          'ENV_VAR2="some data" HANAMI_ENV="staging" DATABASE_URL="mysql2://dbuser:03c1bc98cdd5eb2f9c75@' \
          'dummy-project.c298jfowejf.us-west-2.rds.amazon.com:3265/dummydb" HOME="/home/deploy" USER="deploy" ' \
          'QUEUE=test_queue VERBOSE=1 PIDFILE=/run/lock/dummy_project/resque_dummy_project-2.pid COUNT=2 ' \
          'bundle exec rake environment resque:work 2>&1 | logger -t resque-dummy_project-2\'" ' \
          'with timeout 90 seconds'
        )
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content(
          'stop  program = "/bin/su - deploy -c ' \
          '\'kill -s TERM `cat /run/lock/dummy_project/resque_dummy_project-2.pid`\'' \
          '" with timeout 90 seconds'
        )
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('group resque_dummy_project_group')
      expect(chef_run).to run_execute('monit reload')
    end

    context 'rhel' do
      let(:chef_run_rhel) do
        ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
          deploy = node['deploy']
          deploy['dummy_project']['appserver']['adapter'] = 'puma'
          deploy['dummy_project']['webserver']['adapter'] = 'apache2'
          deploy['dummy_project']['webserver']['keepalive_timeout'] = '65'
          deploy['dummy_project']['framework']['adapter'] = 'hanami'
          deploy['dummy_project']['worker']['adapter'] = 'resque'
          solo_node.set['deploy'] = deploy
        end.converge(described_recipe)
      end

      it 'creates resque.monitrc conf' do
        expect(chef_run_rhel).to create_template("/etc/monit.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('check process resque_dummy_project-1')
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('with pidfile /run/lock/dummy_project/resque_dummy_project-1.pid')
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'start program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
            'ENV_VAR2="some data" HANAMI_ENV="staging" DATABASE_URL="mysql2://dbuser:03c1bc98cdd5eb2f9c75@' \
            'dummy-project.c298jfowejf.us-west-2.rds.amazon.com:3265/dummydb" HOME="/home/deploy" USER="deploy" ' \
            'QUEUE=test_queue VERBOSE=1 PIDFILE=/run/lock/dummy_project/resque_dummy_project-1.pid ' \
            'COUNT=2 bundle exec rake environment resque:work 2>&1 | logger -t resque-dummy_project-1\'" ' \
            'with timeout 90 seconds'
          )
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'stop  program = "/bin/su - deploy -c ' \
            '\'kill -s TERM `cat /run/lock/dummy_project/resque_dummy_project-1.pid`\'' \
            '" with timeout 90 seconds'
          )
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('check process resque_dummy_project-2')
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('with pidfile /run/lock/dummy_project/resque_dummy_project-2.pid')
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'start program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
            'ENV_VAR2="some data" HANAMI_ENV="staging" DATABASE_URL="mysql2://dbuser:03c1bc98cdd5eb2f9c75@' \
            'dummy-project.c298jfowejf.us-west-2.rds.amazon.com:3265/dummydb" HOME="/home/deploy" USER="deploy" ' \
            'QUEUE=test_queue VERBOSE=1 PIDFILE=/run/lock/dummy_project/resque_dummy_project-2.pid ' \
            'COUNT=2 bundle exec rake environment resque:work 2>&1 | logger -t resque-dummy_project-2\'" ' \
            'with timeout 90 seconds'
          )
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'stop  program = "/bin/su - deploy -c ' \
            '\'kill -s TERM `cat /run/lock/dummy_project/resque_dummy_project-2.pid`\'' \
            '" with timeout 90 seconds'
          )
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/resque_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('group resque_dummy_project_group')
        expect(chef_run_rhel).to run_execute('monit reload')
      end

      it 'renders apache2 configuration files in proper place' do
        expect(chef_run_rhel).to render_file("/etc/httpd/ssl/#{aws_opsworks_app['domains'].first}.key")
        expect(chef_run_rhel).to render_file("/etc/httpd/ssl/#{aws_opsworks_app['domains'].first}.crt")
        expect(chef_run_rhel).to render_file("/etc/httpd/ssl/#{aws_opsworks_app['domains'].first}.ca")
        expect(chef_run_rhel).to render_file("/etc/httpd/ssl/#{aws_opsworks_app['domains'].first}.dhparams.pem")
        expect(chef_run_rhel).to render_file("/etc/httpd/sites-available/#{aws_opsworks_app['shortname']}.conf")
        expect(chef_run_rhel).to create_directory('/etc/httpd/ssl')
        expect(chef_run_rhel).to create_link("/etc/httpd/sites-enabled/#{aws_opsworks_app['shortname']}.conf")
      end

      it 'cleans default sites' do
        %w[default default.conf 000-default 000-default.conf default-ssl default-ssl.conf].each do |file|
          expect(chef_run_rhel).to delete_file("/etc/httpd/sites-enabled/#{file}")
        end
      end
    end
  end

  context 'Postgres + Passenger + Apache2' do
    let(:chef_runner) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy['dummy_project']['appserver']['adapter'] = 'passenger'
        deploy['dummy_project']['appserver']['max_pool_size'] = 10
        deploy['dummy_project']['appserver']['min_instances'] = 5
        deploy['dummy_project']['appserver']['mount_point'] = '/some/mount/point'
        deploy['dummy_project']['webserver']['adapter'] = 'apache2'
        deploy['dummy_project']['global']['environment'] = 'production'
        solo_node.set['deploy'] = deploy
      end
    end
    let(:chef_run) { chef_runner.converge(described_recipe) }

    it 'creates apache2 passenger config' do
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content("DocumentRoot /srv/www/#{aws_opsworks_app['shortname']}/current/public")
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ServerTokens Prod')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ServerSignature Off')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('Header always unset "X-Powered-By"')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('<Location /some/mount/point>')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('PassengerAppEnv production')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('PassengerBaseURI /some/mount/point')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('PassengerMaxPoolSize 10')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('PassengerMinInstances 5')
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
      expect(chef_run)
        .to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content("PassengerAppRoot /srv/www/#{aws_opsworks_app['shortname']}/current")
      expect(chef_run)
        .not_to render_file("/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content(' Proxy ')
      expect(chef_run).to create_link("/etc/apache2/sites-enabled/#{aws_opsworks_app['shortname']}.conf")
    end

    it 'creates logrotate file for apache2' do
      expect(chef_run)
        .to enable_logrotate_app("#{aws_opsworks_app['shortname']}-apache2-production")
    end

    it 'creates logrotate file for rails' do
      expect(chef_run)
        .to enable_logrotate_app("#{aws_opsworks_app['shortname']}-rails-production")
    end

    it 'deletes default logrotate file for apache2' do
      expect(chef_run).to disable_logrotate_app('apache2')
    end

    context 'when default ports are overridden' do
      before do
        chef_runner.node.set['deploy'][aws_opsworks_app['shortname']]['webserver']['port'] = 8080
        chef_runner.node.set['deploy'][aws_opsworks_app['shortname']]['webserver']['ssl_port'] = 8443
      end

      it 'listens on the specified ports rather than the default ports' do
        f = "/etc/apache2/sites-available/#{aws_opsworks_app['shortname']}.conf"
        expect(chef_run).to render_file(f).with_content('<VirtualHost *:8080>')
        expect(chef_run).to render_file(f).with_content('Listen 8080')
        expect(chef_run).to render_file(f).with_content('<VirtualHost *:8443>')
        expect(chef_run).to render_file(f).with_content('Listen 8443')
      end
    end
  end

  context 'Sqlite3 + Thin + padrino + delayed_job' do
    let(:dummy_node) do
      node(
        deploy: {
          dummy_project: {
            database: { adapter: 'sqlite3' },
            global: { environment: 'staging' },
            appserver: node['deploy']['dummy_project']['appserver'].merge('adapter' => 'thin'),
            webserver: node['deploy']['dummy_project']['webserver'],
            framework: node['deploy']['dummy_project']['framework'].merge('adapter' => 'padrino'),
            worker: node['deploy']['dummy_project']['worker'].merge('adapter' => 'delayed_job')
          }
        }
      )
    end
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        solo_node.set['deploy'] = dummy_node['deploy']
        solo_node.set['nginx'] = node['nginx']
      end.converge(described_recipe)
    end
    let(:chef_run_rhel) do
      ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
        solo_node.set['deploy'] = dummy_node['deploy']
        solo_node.set['nginx'] = node['nginx']
      end.converge(described_recipe)
    end

    before do
      stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app(data_sources: [])])
      stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([])
    end

    it 'creates proper thin.yml file' do
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/thin.yml")
        .with_content('servers: 4')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/thin.yml")
        .with_content("socket: \"/srv/www/#{aws_opsworks_app['shortname']}/shared/sockets/thin.sock\"")
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/thin.yml")
        .with_content('environment: "staging"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/thin.yml")
        .with_content('max_conns: 4096')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/thin.yml")
        .with_content('timeout: 60')
    end

    it 'creates proper thin.service file' do
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/thin.service")
        .with_content('ENV[\'ENV_VAR1\'] = "test"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/thin.service")
        .with_content('ENV[\'RACK_ENV\'] = "staging"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/thin.service")
        .with_content('ENV[\'HOME\'] = "/home/deploy"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/thin.service")
        .with_content('ENV[\'USER\'] = "deploy"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/thin.service")
        .with_content("APP_NAME=\"#{aws_opsworks_app['shortname']}\"")
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/thin.service")
        .with_content("ROOT_PATH=\"/srv/www/#{aws_opsworks_app['shortname']}\"")
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/thin.service")
        .with_content('DEPLOY_ENV="staging"')
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/thin.service")
        .with_content('thin -C #\{ROOT_PATH\}/shared/config/thin.yml')
    end

    it 'defines thin service' do
      service = chef_run.service("thin_#{aws_opsworks_app['shortname']}")
      expect(service).to do_nothing
      expect(service.start_command)
        .to eq "/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/thin.service start"
      expect(service.stop_command)
        .to eq "/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/thin.service stop"
      expect(service.restart_command)
        .to eq "/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/thin.service restart"
      expect(service.status_command)
        .to eq "/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/thin.service status"
    end

    it 'creates nginx thin proxy handler config' do
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('error_log /var/log/nginx/dummy-project.example.com-ssl.error.log debug;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('upstream thin_dummy-project.example.com {')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('client_max_body_size 125m;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('client_body_timeout 30;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('keepalive_timeout 65;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ssl_certificate_key /etc/nginx/ssl/dummy-project.example.com.key;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ssl_dhparam /etc/nginx/ssl/dummy-project.example.com.dhparams.pem;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ssl_ecdh_curve secp384r1;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ssl_stapling on;')
      expect(chef_run)
        .not_to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('ssl_session_tickets off;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('extra_config {}')
      expect(chef_run)
        .not_to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}.conf")
        .with_content('extra_config_ssl {}')
      expect(chef_run).to create_link("/etc/nginx/sites-enabled/#{aws_opsworks_app['shortname']}.conf")
    end

    it 'creates delayed_job.monitrc conf' do
      expect(chef_run).to create_template("/etc/monit/conf.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('check process delayed_job_dummy_project-1')
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('with pidfile /run/lock/dummy_project/delayed_job.0.pid')
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content(
          'start program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
          'ENV_VAR2="some data" RACK_ENV="staging" DATABASE_URL="sqlite:///srv/www/dummy_project/shared/db/' \
          'data.sqlite3" HOME="/home/deploy" USER="deploy" bin/delayed_job start ' \
          '--pid-dir=/run/lock/dummy_project/ -i 0 --queues=test_queue' \
          ' 2>&1 | logger -t delayed_job-dummy_project-1\'" with timeout 90 seconds'
        )
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content(
          'stop  program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
          'ENV_VAR2="some data" RACK_ENV="staging" DATABASE_URL="sqlite:///srv/www/dummy_project/shared/db/' \
          'data.sqlite3" HOME="/home/deploy" USER="deploy" bin/delayed_job stop ' \
          '--pid-dir=/run/lock/dummy_project/ -i 0\'" ' \
          'with timeout 90 seconds'
        )
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('check process delayed_job_dummy_project-2')
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('with pidfile /run/lock/dummy_project/delayed_job.1.pid')
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content(
          'start program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
          'ENV_VAR2="some data" RACK_ENV="staging" DATABASE_URL="sqlite:///srv/www/dummy_project/shared/db/' \
          'data.sqlite3" HOME="/home/deploy" USER="deploy" bin/delayed_job start ' \
          '--pid-dir=/run/lock/dummy_project/ -i 1 --queues=test_queue' \
          ' 2>&1 | logger -t delayed_job-dummy_project-2\'" with timeout 90 seconds'
        )
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content(
          'stop  program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
          'ENV_VAR2="some data" RACK_ENV="staging" DATABASE_URL="sqlite:///srv/www/dummy_project/shared/db/' \
          'data.sqlite3" HOME="/home/deploy" USER="deploy" bin/delayed_job stop ' \
          '--pid-dir=/run/lock/dummy_project/ -i 1\'" ' \
          'with timeout 90 seconds'
        )
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('group delayed_job_dummy_project_group')
      expect(chef_run).to run_execute('monit reload')
    end

    context 'rhel' do
      it 'creates delayed_job.monitrc conf' do
        expect(chef_run_rhel).to create_template("/etc/monit.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('check process delayed_job_dummy_project-1')
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('with pidfile /run/lock/dummy_project/delayed_job.0.pid')
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'start program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
            'ENV_VAR2="some data" RACK_ENV="staging" DATABASE_URL="sqlite:///srv/www/dummy_project/shared/db/' \
            'data.sqlite3" HOME="/home/deploy" USER="deploy" bin/delayed_job start ' \
            '--pid-dir=/run/lock/dummy_project/ -i 0 ' \
            '--queues=test_queue 2>&1 | logger -t delayed_job-dummy_project-1\'" with timeout 90 seconds'
          )
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'stop  program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
            'ENV_VAR2="some data" RACK_ENV="staging" DATABASE_URL="sqlite:///srv/www/dummy_project/shared/db/' \
            'data.sqlite3" HOME="/home/deploy" USER="deploy" bin/delayed_job stop ' \
            '--pid-dir=/run/lock/dummy_project/ -i 0\'" ' \
            'with timeout 90 seconds'
          )
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('check process delayed_job_dummy_project-2')
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('with pidfile /run/lock/dummy_project/delayed_job.1.pid')
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'start program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
            'ENV_VAR2="some data" RACK_ENV="staging" DATABASE_URL="sqlite:///srv/www/dummy_project/shared/db/' \
            'data.sqlite3" HOME="/home/deploy" USER="deploy" bin/delayed_job start ' \
            '--pid-dir=/run/lock/dummy_project/ -i 1 ' \
            '--queues=test_queue 2>&1 | logger -t delayed_job-dummy_project-2\'" with timeout 90 seconds'
          )
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content(
            'stop  program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
            'ENV_VAR2="some data" RACK_ENV="staging" DATABASE_URL="sqlite:///srv/www/dummy_project/shared/db/' \
            'data.sqlite3" HOME="/home/deploy" USER="deploy" bin/delayed_job stop ' \
            '--pid-dir=/run/lock/dummy_project/ -i 1\'" ' \
            'with timeout 90 seconds'
          )
        expect(chef_run_rhel)
          .to render_file("/etc/monit.d/delayed_job_#{aws_opsworks_app['shortname']}.monitrc")
          .with_content('group delayed_job_dummy_project_group')
        expect(chef_run_rhel).to run_execute('monit reload')
      end
    end
  end

  context 'No RDS (Database defined in node)' do
    let(:supplied_node) do
      node(deploy: {
             dummy_project: {
               database: {
                 adapter: 'postgresql',
                 username: 'user_936',
                 password: 'password_936',
                 host: 'dummy-project.936.us-west-2.rds.amazon.com',
                 database: 'database_936'
               },
               global: { environment: 'staging' },
               framework: { adapter: 'rails' }
             }
           })
    end
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        solo_node.set['deploy'] = supplied_node['deploy']
      end.converge(described_recipe)
    end

    before do
      stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app(data_sources: [])])
      stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([])
    end

    it 'creates proper database.yml template' do
      db_config = Drivers::Db::Postgresql.new(chef_run, aws_opsworks_app(data_sources: [])).out
      expect(db_config[:adapter]).to eq 'postgresql'
      expect(db_config[:username]).to eq 'user_936'
      expect(db_config[:password]).to eq 'password_936'
      expect(db_config[:host]).to eq 'dummy-project.936.us-west-2.rds.amazon.com'
      expect(db_config[:database]).to eq 'database_936'
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/database.yml").with_content(
          JSON.parse({ development: db_config, production: db_config, staging: db_config }.to_json).to_yaml
        )
    end

    context '"null" database adapter' do
      let(:supplied_node) do
        node(deploy: {
               dummy_project: {
                 database: {
                   adapter: 'null'
                 },
                 global: { environment: 'production' },
                 framework: { adapter: 'rails' }
               }
             })
      end

      before do
        stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app(data_sources: [])])
        stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([])
      end

      it 'does not create a database.yml file' do
        db_config = Drivers::Db::Null.new(chef_run, aws_opsworks_app(data_sources: [])).out
        expect(db_config[:adapter]).to eq 'null'
        expect(db_config[:username]).not_to be
        expect(db_config[:password]).not_to be
        expect(db_config[:host]).not_to be
        expect(db_config[:database]).not_to be
        expect(chef_run).not_to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/database.yml")
      end
    end
  end

  context 'empty node[\'deploy\']' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        solo_node.set['lsb'] = node['lsb']
      end.converge(described_recipe)
    end

    it 'not raises error' do
      expect do
        chef_run
      end.not_to raise_error
    end

    it 'creates logrotate file for rails' do
      expect(chef_run)
        .to enable_logrotate_app("#{aws_opsworks_app['shortname']}-rails-production")
    end

    it 'creates logrotate file for rails' do
      expect(chef_run)
        .to enable_logrotate_app("#{aws_opsworks_app['shortname']}-nginx-production")
    end
  end
end
