# frozen_string_literal: true

#
# Cookbook Name:: opsworks_ruby
# Recipe:: setup
#

prepare_recipe

# Monit and cleanup
if node['platform_family'] == 'debian'
  execute 'mkdir -p /etc/monit/conf.d'

  file '/etc/monit/conf.d/00_httpd.monitrc' do
    content "set httpd port 2812 and\n    use address localhost\n    allow localhost"
  end

  apt_package 'javascript-common' do
    action :purge
  end
end

# Ruby and bundler
include_recipe 'deployer'
if node['platform_family'] == 'debian'
  include_recipe 'ruby-ng::dev'
else
  ruby_pkg_version = node['ruby-ng']['ruby_version'].split('.')[0..1]
  package "ruby#{ruby_pkg_version.join('')}"
  package "ruby#{ruby_pkg_version.join('')}-devel"
  execute "/usr/sbin/alternatives --set ruby /usr/bin/ruby#{ruby_pkg_version.join('.')}"
end

apt_repository 'apache2' do
  uri 'http://ppa.launchpad.net/ondrej/apache2/ubuntu'
  distribution node['lsb']['codename']
  components %w[main]
  keyserver 'keyserver.ubuntu.com'
  key 'E5267A6C'
  only_if { node['defaults']['webserver']['use_apache2_ppa'] }
end

gem_package 'bundler' do
  action :install
end

if node['platform_family'] == 'debian'
  link '/usr/local/bin/bundle' do
    to '/usr/bin/bundle'
  end
else
  link '/usr/local/bin/bundle' do
    to '/usr/local/bin/bundler'
  end
end

execute 'yum-config-manager --enable epel' if node['platform_family'] == 'rhel'

every_enabled_application do |application|
  databases = []
  every_enabled_rds(self, application) do |rds|
    databases.push(Drivers::Db::Factory.build(self, application, rds: rds))
  end

  source = Drivers::Source::Factory.build(self, application)
  framework = Drivers::Framework::Factory.build(self, application, databases: databases)
  appserver = Drivers::Appserver::Factory.build(self, application)
  worker = Drivers::Worker::Factory.build(self, application, databases: databases)
  webserver = Drivers::Webserver::Factory.build(self, application)

  fire_hook(:setup, items: databases + [source, framework, appserver, worker, webserver])
end
