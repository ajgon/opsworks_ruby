# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Recipe:: configure
#

prepare_recipe

every_enabled_application do |application, _deploy|
  create_deploy_dir(application, File.join('shared'))
  create_deploy_dir(application, File.join('shared', 'config'))
  create_deploy_dir(application, File.join('shared', 'log'))
  create_deploy_dir(application, File.join('shared', 'pids'))
  create_deploy_dir(application, File.join('shared', 'scripts'))
  create_deploy_dir(application, File.join('shared', 'sockets'))

  every_enabled_rds do |rds|
    database = Drivers::Db::Factory.build(application, node, rds: rds)
    database.configure(self)
  end

  if rdses.blank?
    database = Drivers::Db::Factory.build(application, node)
    database.configure(self)
  end

  scm = Drivers::Scm::Factory.build(application, node)
  scm.configure(self)
  framework = Drivers::Framework::Factory.build(application, node)
  framework.configure(self)
  appserver = Drivers::Appserver::Factory.build(application, node)
  appserver.configure(self)
  worker = Drivers::Worker::Factory.build(application, node)
  worker.configure(self)
  webserver = Drivers::Webserver::Factory.build(application, node)
  webserver.configure(self)
end
