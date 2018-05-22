# frozen_string_literal: true

# deployer
default['deployer']['user'] = 'deploy'
default['deployer']['group'] = 'deploy'
default['deployer']['home'] = "/home/#{default['deployer']['user']}"

# ruby
default['build-essential']['compile_time'] = true
default['ruby-ng']['ruby_version'] = node['ruby'].try(:[], 'version') || '2.5'
default['nginx']['source']['modules'] = %w[
  nginx::http_ssl_module nginx::http_realip_module nginx::http_gzip_static_module nginx::headers_more_module
  nginx::http_stub_status_module
]

default['deploy']['timeout'] = 600

# global
default['defaults']['global']['environment'] = 'production'
default['defaults']['global']['symlinks'] = {
  'system' => 'public/system',
  'assets' => 'public/assets',
  'cache' => 'tmp/cache',
  'pids' => 'tmp/pids',
  'log' => 'log'
}
default['defaults']['global']['create_dirs_before_symlink'] =
  %w[tmp public config ../../shared/cache ../../shared/assets]
default['defaults']['global']['purge_before_symlink'] = %w[log tmp/cache tmp/pids public/system public/assets]
default['defaults']['global']['rollback_on_error'] = true
default['defaults']['global']['logrotate_rotate'] = 30
default['defaults']['global']['logrotate_frequency'] = 'daily'
default['defaults']['global']['logrotate_options'] = %w[
  missingok compress delaycompress notifempty copytruncate sharedscripts
]

# database
## common

default['defaults']['database']['adapter'] = 'sqlite3'

# source
## common

default['defaults']['source']['adapter'] = 'git'
default['defaults']['source']['remove_scm_files'] = true

# appserver
## common

default['defaults']['appserver']['adapter'] = 'puma'
default['defaults']['appserver']['application_yml'] = false
default['defaults']['appserver']['dot_env'] = false
default['defaults']['appserver']['preload_app'] = true
default['defaults']['appserver']['timeout'] = 60
default['defaults']['appserver']['worker_processes'] = 4

## puma

default['defaults']['appserver']['log_requests'] = false
default['defaults']['appserver']['thread_min'] = 0
default['defaults']['appserver']['thread_max'] = 16

## thin

default['defaults']['appserver']['max_connections'] = 1024
default['defaults']['appserver']['max_persistent_connections'] = 512

## unicorn

default['defaults']['appserver']['backlog'] = 1024
default['defaults']['appserver']['delay'] = 0.5
default['defaults']['appserver']['tcp_nodelay'] = true
default['defaults']['appserver']['tcp_nopush'] = false
default['defaults']['appserver']['tries'] = 5

## passenger
default['defaults']['appserver']['mount_point'] = '/'

# webserver
## common

default['defaults']['webserver']['adapter'] = 'nginx'
default['defaults']['webserver']['port'] = 80
default['defaults']['webserver']['ssl_port'] = 443
default['defaults']['webserver']['ssl_for_legacy_browsers'] = false
default['defaults']['webserver']['extra_config'] = ''
default['defaults']['webserver']['extra_config_ssl'] = ''
default['defaults']['webserver']['keepalive_timeout'] = '15'
default['defaults']['webserver']['log_level'] = 'info'
default['defaults']['webserver']['remove_default_sites'] = %w[
  default default.conf 000-default 000-default.conf default-ssl default-ssl.conf
]

## apache2

default['defaults']['webserver']['limit_request_body'] = '1048576'
default['defaults']['webserver']['proxy_timeout'] = '60'
default['defaults']['webserver']['use_apache2_ppa'] = (node['platform'] == 'ubuntu')

## nginx

# These are parameters, directly for the `nginx` cookbook, not the `webserver` part!
default['nginx']['build_type'] = 'default'
default['nginx']['default_site_enabled'] = false
default['nginx']['client_body_timeout'] = '12'
default['nginx']['client_header_timeout'] = '12'
default['nginx']['client_max_body_size'] = '10m'
default['nginx']['log_dir'] = '/var/log/nginx'
default['nginx']['proxy_read_timeout'] = '60'
default['nginx']['proxy_send_timeout'] = '60'
default['nginx']['send_timeout'] = '10'
default['nginx']['enable_upgrade_method'] = false

# framework
## common

default['defaults']['framework']['adapter'] = 'rails'

## rails

default['defaults']['framework']['migrate'] = true
default['defaults']['framework']['migration_command'] =
  'case $(/usr/local/bin/bundle exec rake db:version 2>&1) in ' \
  '*"ActiveRecord::NoDatabaseError"*) /usr/local/bin/bundle exec rake db:setup;; ' \
  '*) /usr/local/bin/bundle exec rake db:migrate;; ' \
  'esac'
default['defaults']['framework']['assets_precompile'] = true
default['defaults']['framework']['assets_precompilation_command'] = '/usr/local/bin/bundle exec rake assets:precompile'
default['defaults']['framework']['envs_in_console'] = false

# worker
## common

default['defaults']['worker']['adapter'] = 'null'
default['defaults']['worker']['process_count'] = 2
default['defaults']['worker']['syslog'] = true

default['monit']['basedir'] = if platform?('centos', 'redhat', 'fedora', 'amazon')
                                '/etc/monit.d'
                              else
                                '/etc/monit/conf.d'
                              end

## sidekiq

default['defaults']['worker']['config'] = { 'concurrency' => 5, 'verbose' => false, 'queues' => ['default'] }

## resque

default['defaults']['worker']['queues'] = '*'
default['defaults']['worker']['workers'] = 2
