# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Spec:: configure
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'opsworks_ruby::configure' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
      solo_node.set['deploy'] = node['deploy']
      solo_node.set['nginx'] = node['nginx']
    end.converge(described_recipe)
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

    it 'creates shared/pids' do
      expect(chef_run).to create_directory("/srv/www/#{aws_opsworks_app['shortname']}/shared/pids")
    end

    it 'creates shared/scripts' do
      expect(chef_run).to create_directory("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts")
    end

    it 'creates shared/sockets' do
      expect(chef_run).to create_directory("/srv/www/#{aws_opsworks_app['shortname']}/shared/sockets")
    end
  end

  context 'Postgresql + Git + Unicorn + Nginx + Sidekiq' do
    it 'creates proper database.yml template' do
      db_config = Drivers::Db::Postgresql.new(aws_opsworks_app, node, rds: aws_opsworks_rds_db_instance).out
      expect(db_config[:adapter]).to eq 'postgresql'
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/database.yml").with_content(
          JSON.parse({ development: db_config, production: db_config }.to_json).to_yaml
        )
    end

    it 'creates proper unicorn.conf file' do
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/unicorn.conf")
        .with_content('ENV[\'ENV_VAR1\'] = "test"')
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
        .with_content("APP_NAME=\"#{aws_opsworks_app['shortname']}\"")
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/unicorn.service")
        .with_content("ROOT_PATH=\"/srv/www/#{aws_opsworks_app['shortname']}\"")
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/scripts/unicorn.service")
        .with_content('unicorn_rails --env production')
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
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}")
        .with_content('client_max_body_size 125m;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}")
        .with_content('keepalive_timeout 15;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}")
        .with_content('ssl_certificate_key /etc/nginx/ssl/dummy-project.example.com.key;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}")
        .with_content('ssl_dhparam /etc/nginx/ssl/dummy-project.example.com.dhparams.pem;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}")
        .with_content('ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}")
        .with_content('ssl_ecdh_curve secp384r1;')
      expect(chef_run)
        .to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}")
        .with_content('ssl_stapling on;')
      expect(chef_run)
        .not_to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}")
        .with_content('ssl_session_tickets off;')
      expect(chef_run).to create_link("/etc/nginx/sites-enabled/#{aws_opsworks_app['shortname']}")
    end

    it 'enables ssl rules for legacy browsers in nginx config' do
      chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy[aws_opsworks_app['shortname']]['webserver']['ssl_for_legacy_browsers'] = true
        solo_node.set['deploy'] = deploy
        solo_node.set['nginx'] = node['nginx']
      end.converge(described_recipe)
      expect(chef_run).to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}").with_content(
        'ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH:ECDHE-RSA-AES128-GCM-SHA384:' \
        'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA128:DHE-RSA-AES128-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:' \
        'DHE-RSA-AES128-GCM-SHA128:ECDHE-RSA-AES128-SHA384:ECDHE-RSA-AES128-SHA128:ECDHE-RSA-AES128-SHA:' \
        'ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA128:DHE-RSA-AES128-SHA128:DHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA:' \
        'ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA384:AES128-GCM-SHA128:AES128-SHA128:AES128-SHA128:' \
        'AES128-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";'
      )
      expect(chef_run)
        .not_to render_file("/etc/nginx/sites-available/#{aws_opsworks_app['shortname']}")
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

    it 'creates sidekiq.conf.yml' do
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/sidekiq_1.yml")
        .with_content("---\nconcurency: 5\nverbose: false\nqueues:\n- default")
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/sidekiq_2.yml")
        .with_content("---\nconcurency: 5\nverbose: false\nqueues:\n- default")
    end

    it 'creates sidekiq.monitrc conf' do
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('check process sidekiq_dummy_project-1')
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('with pidfile /srv/www/dummy_project/shared/pids/sidekiq_dummy_project-1.pid')
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content(
          'start program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
          'ENV_VAR2="some data" RAILS_ENV="production" bundle exec sidekiq ' \
          '-C /srv/www/dummy_project/shared/config/sidekiq_1.yml ' \
          '-P /srv/www/dummy_project/shared/pids/sidekiq_dummy_project-1.pid ' \
          '-r /srv/www/dummy_project/current/lorem_ipsum.rb 2>&1 ' \
          '| logger -t sidekiq-dummy_project-1\'" with timeout 90 seconds'
        )
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content(
          'stop  program = "/bin/su - deploy -c ' \
          '\'kill -s TERM `cat /srv/www/dummy_project/shared/pids/sidekiq_dummy_project-1.pid`\'' \
          '" with timeout 90 seconds'
        )
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('check process sidekiq_dummy_project-2')
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('with pidfile /srv/www/dummy_project/shared/pids/sidekiq_dummy_project-2.pid')
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content(
          'start program = "/bin/su - deploy -c \'cd /srv/www/dummy_project/current && ENV_VAR1="test" ' \
          'ENV_VAR2="some data" RAILS_ENV="production" bundle exec sidekiq ' \
          '-C /srv/www/dummy_project/shared/config/sidekiq_2.yml ' \
          '-P /srv/www/dummy_project/shared/pids/sidekiq_dummy_project-2.pid ' \
          '-r /srv/www/dummy_project/current/lorem_ipsum.rb 2>&1 ' \
          '| logger -t sidekiq-dummy_project-2\'" with timeout 90 seconds'
        )
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content(
          'stop  program = "/bin/su - deploy -c ' \
          '\'kill -s TERM `cat /srv/www/dummy_project/shared/pids/sidekiq_dummy_project-2.pid`\'' \
          '" with timeout 90 seconds'
        )
      expect(chef_run)
        .to render_file("/etc/monit/conf.d/sidekiq_#{aws_opsworks_app['shortname']}.monitrc")
        .with_content('group sidekiq_dummy_project_group')
    end
  end

  context 'Mysql' do
    before do
      stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([aws_opsworks_rds_db_instance(engine: 'mysql')])
    end

    it 'creates proper database.yml template' do
      db_config = Drivers::Db::Mysql.new(aws_opsworks_app, node, rds: aws_opsworks_rds_db_instance(engine: 'mysql')).out
      expect(db_config[:adapter]).to eq 'mysql2'
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/database.yml").with_content(
          JSON.parse({ development: db_config, production: db_config }.to_json).to_yaml
        )
    end
  end

  context 'Sqlite3' do
    let(:dummy_node) do
      node(deploy: { dummy_project: { database: { adapter: 'sqlite3' } } })
    end
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        solo_node.set['deploy'] = dummy_node['deploy']
      end.converge(described_recipe)
    end

    before do
      stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app(data_sources: [])])
      stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([])
    end

    it 'creates proper database.yml template' do
      db_config = Drivers::Db::Sqlite.new(
        aws_opsworks_app(data_sources: []), dummy_node, rds: aws_opsworks_rds_db_instance(engine: 'sqlite3')
      ).out
      expect(db_config[:adapter]).to eq 'sqlite3'
      expect(db_config[:database]).to eq 'db/data.sqlite3'
      expect(chef_run)
        .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/database.yml").with_content(
          JSON.parse({ development: db_config, production: db_config }.to_json).to_yaml
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
