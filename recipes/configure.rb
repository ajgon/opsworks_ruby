# frozen_string_literal: true

#
# Cookbook Name:: opsworks_ruby
# Recipe:: configure
#

prepare_recipe

every_enabled_application do |application|
  create_deploy_dir(application, File.join('shared'))
  create_deploy_dir(application, File.join('shared', 'config'))
  create_deploy_dir(application, File.join('shared', 'log'))
  create_deploy_dir(application, File.join('shared', 'scripts'))
  create_deploy_dir(application, File.join('shared', 'sockets'))
  create_deploy_dir(application, File.join('shared', 'vendor/bundle'))
  create_dir("/run/lock/#{application['shortname']}")
  link File.join(deploy_dir(application), 'shared', 'pids') do
    to "/run/lock/#{application['shortname']}"
  end

  databases = []
  every_enabled_rds(self, application) do |rds|
    databases.push(Drivers::Db::Factory.build(self, application, rds: rds))
  end

  scm = Drivers::Scm::Factory.build(self, application)
  framework = Drivers::Framework::Factory.build(self, application, databases: databases)
  appserver = Drivers::Appserver::Factory.build(self, application, databases: databases)
  worker = Drivers::Worker::Factory.build(self, application, databases: databases)
  webserver = Drivers::Webserver::Factory.build(self, application)

  fire_hook(:configure, items: databases + [scm, framework, appserver, worker, webserver])
end
