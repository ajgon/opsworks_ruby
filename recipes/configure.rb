# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Recipe:: configure
#

every_enabled_application do |application, _deploy|
  create_deploy_dir(application, File.join('shared', 'config'))

  every_enabled_rds do |rds|
    database = Drivers::Db::Factory.build(application, node, rds: rds)
    database.configure(self)
  end
end
