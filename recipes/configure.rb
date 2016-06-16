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

  fire_hook(:configure, context: self, items: databases + [scm, framework, appserver, worker, webserver])
end
