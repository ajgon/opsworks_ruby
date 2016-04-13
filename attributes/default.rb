# frozen_string_literal: true
# ruby

default['build-essential']['compile_time'] = true
default['ruby-ng']['ruby_version'] = node['ruby'].try(:[], 'version') || '2.3'

# appserver
## common

default['defaults']['appserver']['worker_processes'] = 4
default['defaults']['appserver']['adapter'] = 'unicorn'

## unicorn

default['defaults']['appserver']['accept_filter'] = 'httpready'
default['defaults']['appserver']['backlog'] = 1024
default['defaults']['appserver']['delay'] = 0.5
default['defaults']['appserver']['preload_app'] = true
default['defaults']['appserver']['tcp_nodelay'] = true
default['defaults']['appserver']['tcp_nopush'] = false
default['defaults']['appserver']['tries'] = 5
default['defaults']['appserver']['timeout'] = 60
