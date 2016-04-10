# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Recipe:: setup
#

if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
end

applications = search(:aws_opsworks_app)
rdses = search(:aws_opsworks_rds_db_instance)

node['deploy'].each do |deploy_app_id, _deploy|
  application = applications.detect { |app| app['id'] == deploy_app_id }
  next unless application
  rdses.each do |rds|
    database = Drivers::Db::Factory.build(application, node, rds: rds)
    database.setup(self)
  end
end
