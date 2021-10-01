# frozen_string_literal: true

#
# Cookbook Name:: opsworks_ruby
# Recipe:: setup
#



module GemInstallDecorator
  # Patch Added:       12-10-2020
  # Required for:      Ruby Version >= 2.6
  # Reason:            Patching gem install due to "--no-rdoc" & "--no-ri" has been deprecated to just "--no-document"
  # Other ways to fix: Update Chef / Opsworks_ruby
  #     - Will require us to update our Infrastructure to Ubuntu 18 LTS (we're 16 LTS)
  #     - Will require us to also transfer some of our "custom" changes too
  def install_via_gem_command(name, version)
    if new_resource.source =~ /\.gem$/i
      name = new_resource.source
    elsif new_resource.clear_sources
      src = " --clear-sources"
      src << (new_resource.source && " --source=#{new_resource.source}" || "")
    else
      src = new_resource.source && " --source=#{new_resource.source} --source=#{Chef::Config[:rubygems_url]}"
    end
    if !version.nil? && !version.empty?
      shell_out_with_timeout!("#{gem_binary_path} install #{name} -q --no-document -v \"#{version}\"#{src}#{opts}", env: nil)
    else
      shell_out_with_timeout!("#{gem_binary_path} install \"#{name}\" -q --no-document #{src}#{opts}", env: nil)
    end
  end
end

::Chef::Provider::Package::Rubygems.prepend(GemInstallDecorator)

prepare_recipe

# Install additional packages set in configuration
if node['additional_packages'] && node['additional_packages'].is_a?(Array)
  node['additional_packages'].each do |package|
    apt_package(package)
  end
end

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

# Install Ruby, either via rbenv or ng-ruby
if node['rbenv']
  # Install Ruby via rbenv
  ruby_version    = node['rbenv']['ruby_version']
  deploy_user     = node['deployer']['user'] || root

  # Install rbenv for deploy user
  rbenv_user_install(deploy_user)

  # Install a specified ruby_version for deploy user
  rbenv_ruby(ruby_version) do
    user(deploy_user)
  end

  # Globally set ruby_version for deploy user
  rbenv_global(ruby_version) do
    user(deploy_user)
  end

  # rbenv aware bundler install
  rbenv_gem 'bundler' do
    user deploy_user
    rbenv_version ruby_version
  end
else
  # Install Ruby via ng-ruby
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
end

execute 'yum-config-manager --enable epel' if node['platform_family'] == 'rhel'

cookbook_file 'nginx_signing_key' do
  path '/var/lib/aws/opsworks/nginx_signing.key'
  source 'nginx_signing.key'
  owner 'root'
  group 'aws'
  mode '0644'
end


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
