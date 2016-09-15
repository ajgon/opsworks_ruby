# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Recipe:: shutdown
#

prepare_recipe

every_enabled_application do |application, _deploy|
  databases = []
  every_enabled_rds(application) do |rds|
    databases.push(Drivers::Db::Factory.build(application, node, rds: rds))
  end

  scm = Drivers::Scm::Factory.build(application, node)
  framework = Drivers::Framework::Factory.build(application, node, databases: databases)
  appserver = Drivers::Appserver::Factory.build(application, node)
  worker = Drivers::Worker::Factory.build(application, node, databases: databases)
  webserver = Drivers::Webserver::Factory.build(application, node)

  fire_hook(:shutdown, context: self, items: databases + [scm, framework, appserver, worker, webserver])
end
