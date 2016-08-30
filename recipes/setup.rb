# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Recipe:: setup
#

prepare_recipe

# Ruby and bundler
include_recipe 'deployer'

if node['ruby']['install_method'] == 'ruby_build'
  include_recipe 'ruby_build'
  ruby_build_ruby node['ruby-ng']['ruby_version'] do
    prefix_path '/usr/local'
  end
  gem_package 'bundler' do
    gem_binary '/usr/local/bin/gem'
  end
elsif node['platform_family'] == 'debian'
  include_recipe 'ruby-ng::dev'
  gem_package 'bundler'
else
  ruby_pkg_version = node['ruby-ng']['ruby_version'].split('.')[0..1]
  package "ruby#{ruby_pkg_version.join('')}"
  package "ruby#{ruby_pkg_version.join('')}-devel"
  execute "/usr/sbin/alternatives --set ruby /usr/bin/ruby#{ruby_pkg_version.join('.')}"
  gem_package 'bundler'
end

if node['platform_family'] == 'debian'
  link '/usr/local/bin/bundle' do
    to '/usr/bin/bundle'
    not_if { ::File.exist?('/usr/local/bin/bundle') }
  end
else
  link '/usr/local/bin/bundle' do
    to '/usr/local/bin/bundler'
    not_if { ::File.exist?('/usr/local/bin/bundle') }
  end
end
every_enabled_application do |application, _deploy|
  databases = []
  every_enabled_rds do |rds|
    databases.push(Drivers::Db::Factory.build(application, node, rds: rds))
  end

  databases = [Drivers::Db::Factory.build(application, node)] if rdses.blank?

  scm = Drivers::Scm::Factory.build(application, node)
  framework = Drivers::Framework::Factory.build(application, node)
  appserver = Drivers::Appserver::Factory.build(application, node)
  worker = Drivers::Worker::Factory.build(application, node)
  webserver = Drivers::Webserver::Factory.build(application, node)

  fire_hook(:setup, context: self, items: databases + [scm, framework, appserver, worker, webserver])
end
