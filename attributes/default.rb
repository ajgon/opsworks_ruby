# frozen_string_literal: true
# ruby

default['build-essential']['compile_time'] = true
default['ruby-ng']['ruby_version'] = node['ruby'].try(:[], 'version') || '2.3'

# appserver
## common

default['appserver']['worker_processes'] = 4

## unicorn

default['appserver']['accept_filter'] = 'httpready'
default['appserver']['backlog'] = 1024
default['appserver']['delay'] = 0.5
default['appserver']['preload_app'] = true
default['appserver']['tcp_nodelay'] = true
default['appserver']['tcp_nopush'] = false
default['appserver']['tries'] = 5
default['appserver']['timeout'] = 60
