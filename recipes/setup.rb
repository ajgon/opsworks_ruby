# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Recipe:: setup
#

# Ruby and bundler
include_recipe 'deployer'
include_recipe 'ruby-ng::dev'

gem_package 'bundler'
link '/usr/local/bin/bundle' do
  to '/usr/bin/bundle'
end

every_enabled_application do |application|
  scm = Drivers::Scm::Factory.build(application, node)
  scm.setup(self)
  webserver = Drivers::Webserver::Factory.build(application, node)
  webserver.setup(self)

  every_enabled_rds do |rds|
    database = Drivers::Db::Factory.build(application, node, rds: rds)
    database.setup(self)
  end
end
