# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Recipe:: setup
#

prepare_recipe

# Ruby and bundler
include_recipe 'deployer'
include_recipe 'rvm::default'
include_recipe 'rvm::system'

apt_repository 'apache2' do
  uri 'http://ppa.launchpad.net/ondrej/apache2/ubuntu'
  distribution node['lsb']['codename']
  components %w(main)
  keyserver 'keyserver.ubuntu.com'
  key 'E5267A6C'
  only_if { node['platform'] == 'ubuntu' }
end

link '/usr/local/bin/ruby' do
  to "/usr/local/rvm/wrappers/ruby-#{node['rvm']['default_ruby']}@global/ruby"
end

if node['platform_family'] == 'debian'
  link '/usr/local/bin/bundle' do
    to "/usr/local/rvm/wrappers/ruby-#{node['rvm']['default_ruby']}@global/bundle"
  end
else
  link '/usr/local/bin/bundle' do
    to "/usr/local/rvm/wrappers/ruby-#{node['rvm']['default_ruby']}@global/bundler"
  end
end

execute 'yum-config-manager --enable epel' if node['platform_family'] == 'rhel'

every_enabled_application do |application|
  databases = []
  every_enabled_rds(self, application) do |rds|
    databases.push(Drivers::Db::Factory.build(self, application, rds: rds))
  end

  scm = Drivers::Scm::Factory.build(self, application)
  framework = Drivers::Framework::Factory.build(self, application, databases: databases)
  appserver = Drivers::Appserver::Factory.build(self, application)
  worker = Drivers::Worker::Factory.build(self, application, databases: databases)
  webserver = Drivers::Webserver::Factory.build(self, application)

  fire_hook(:setup, items: databases + [scm, framework, appserver, worker, webserver])
end
