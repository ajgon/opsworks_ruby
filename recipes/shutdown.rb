# frozen_string_literal: true

#
# Cookbook Name:: opsworks_ruby
# Recipe:: shutdown
#

prepare_recipe

every_enabled_application do |application|
  databases = []
  every_enabled_rds(self, application) do |rds|
    databases.push(Drivers::Db::Factory.build(self, application, rds: rds))
  end

  scm       = Drivers::Scm::Factory.build(self, application)
  framework = Drivers::Framework::Factory.build(self, application, databases: databases)
  appserver = Drivers::Appserver::Factory.build(self, application)
  worker    = Drivers::Worker::Factory.build(self, application, databases: databases)
  webserver = Drivers::Webserver::Factory.build(self, application)
  items     = databases + [scm, framework, appserver, worker, webserver]

  if node['hutch_server'] && node['hutch_server']['enabled']
    items << Drivers::Worker::Hutch.new(self, application, databases: databases)
  end


  fire_hook(:shutdown, items: items)
end
