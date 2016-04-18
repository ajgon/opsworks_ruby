# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Recipe:: shutdown
#

prepare_recipe

every_enabled_application do |application, _deploy|
  every_enabled_rds do |rds|
    database = Drivers::Db::Factory.build(application, node, rds: rds)
    database.shutdown(self)
  end

  scm = Drivers::Scm::Factory.build(application, node)
  scm.shutdown(self)
  framework = Drivers::Framework::Factory.build(application, node)
  framework.shutdown(self)
  appserver = Drivers::Appserver::Factory.build(application, node)
  appserver.shutdown(self)
  webserver = Drivers::Webserver::Factory.build(application, node)
  webserver.shutdown(self)
end
