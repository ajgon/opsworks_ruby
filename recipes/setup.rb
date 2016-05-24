# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Recipe:: setup
#

prepare_recipe

# Ruby and bundler
include_recipe 'deployer'
if node['platform_family'] == 'debian'
  include_recipe 'ruby-ng::dev'
else
  ruby_pkg_version = node['ruby-ng']['ruby_version'].split('.')[0..1]
  package "ruby#{ruby_pkg_version.join('')}"
  package "ruby#{ruby_pkg_version.join('')}-devel"
  execute "/usr/sbin/alternatives --set ruby /usr/bin/ruby#{ruby_pkg_version.join('.')}"
end

gem_package 'bundler'
if node['platform_family'] == 'debian'
  link '/usr/local/bin/bundle' do
    to '/usr/bin/bundle'
  end
else
  link '/usr/local/bin/bundle' do
    to '/usr/local/bin/bundler'
  end
end
every_enabled_application do |application, _deploy|
  every_enabled_rds do |rds|
    database = Drivers::Db::Factory.build(application, node, rds: rds)
    database.setup(self)
  end

  if rdses.blank?
    database = Drivers::Db::Factory.build(application, node)
    database.setup(self)
  end

  scm = Drivers::Scm::Factory.build(application, node)
  scm.setup(self)
  framework = Drivers::Framework::Factory.build(application, node)
  framework.setup(self)
  appserver = Drivers::Appserver::Factory.build(application, node)
  appserver.setup(self)
  worker = Drivers::Worker::Factory.build(application, node)
  worker.setup(self)
  webserver = Drivers::Webserver::Factory.build(application, node)
  webserver.setup(self)
end
