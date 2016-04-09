# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Recipe:: configure
#

if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
end

app = search(:aws_opsworks_app).first
rds = search(:aws_opsworks_rds_db_instance).first

database = Drivers::Db::Factory.build(app, node, rds: rds)
database.configure(self)
