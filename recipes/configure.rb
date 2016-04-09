#
# Cookbook Name:: opsworks_ruby
# Recipe:: configure
#

app = search(:aws_opsworks_app).first
rds = search(:aws_opsworks_rds_db_instance).first

database = Drivers::Db::Factory.build(app, node, rds: rds)
database.configure(self)
