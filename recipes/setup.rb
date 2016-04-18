# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Recipe:: setup
#

prepare_recipe

# Ruby and bundler
include_recipe 'deployer'
include_recipe 'ruby-ng::dev'

gem_package 'bundler'
link '/usr/local/bin/bundle' do
  to '/usr/bin/bundle'
end

every_enabled_application do |application, _deploy|
  every_enabled_rds do |rds|
    database = Drivers::Db::Factory.build(application, node, rds: rds)
    database.setup(self)
  end

  scm = Drivers::Scm::Factory.build(application, node)
  scm.setup(self)
  framework = Drivers::Framework::Factory.build(application, node)
  framework.setup(self)
  appserver = Drivers::Appserver::Factory.build(application, node)
  appserver.setup(self)
  webserver = Drivers::Webserver::Factory.build(application, node)
  webserver.setup(self)
end
