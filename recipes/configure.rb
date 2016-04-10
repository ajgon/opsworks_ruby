# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Recipe:: configure
#

every_enabled_application do |application, _deploy|
  every_enabled_rds do |rds|
    database = Drivers::Db::Factory.build(application, node, rds: rds)
    template File.join(create_deploy_dir(application, File.join('shared', 'config')), 'database.yml') do
      source 'database.yml.erb'
      mode '0660'
      owner node['deployer']['user'] || 'root'
      group www_group
      variables(database: database.out, environment: application['attributes']['rails_env'])
    end
  end
end
