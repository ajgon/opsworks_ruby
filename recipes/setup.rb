# frozen_string_literal: true

#
# Cookbook Name:: opsworks_ruby
# Recipe:: setup
#

include_recipe 'apt'

prepare_recipe

# Upgrade chef
# Taken from `chef-upgrade` cookbook <https://github.com/inopinatus/chef-upgrade> by Josh Goodall
# The Chef updater will try to kill its own process. This causes setup failure.
# We force it to accept our "exec" configuration by monkey-patching the LWRP.
if node['chef-version']
  update_provider = Chef.provider_handler_map.get(node, :chef_client_updater)
  update_provider.prepend(CannotSelfTerminate)
  include_recipe 'chef_client_updater::default'

  directory '/opt/aws/opsworks/current/plugins' do
    owner 'root'
    group 'aws'
    mode '0755'
    recursive true
  end

  cookbook_file '/opt/aws/opsworks/current/plugins/debian_downgrade_protection.rb' do
    source 'debian_downgrade_protection.rb'
    owner 'root'
    group 'aws'
    mode '0644'
  end
end

# Create deployer user
group node['deployer']['group'] do
  gid 5000
end

user node['deployer']['user'] do
  comment 'The deployment user'
  uid 5000
  gid 5000
  shell '/bin/bash'
  home node['deployer']['home']
  manage_home true
end

sudo node['deployer']['user'] do
  user      node['deployer']['user']
  group     node['deployer']['group']
  commands  %w[ALL]
  host      'ALL'
  nopasswd  true
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

if node['use-nodejs']
  # NodeJS and Yarn
  include_recipe 'nodejs'
  include_recipe 'yarn'
end

# Ruby and bundler
if node['ruby-provider'] == 'fullstaq'
  # fullstaq-ruby provider
  if node['platform_family'] == 'debian'
    package 'gnupg2'

    # For whatever reason `apt_repository.key` doesn't work here.
    remote_file "#{Chef::Config[:file_cache_path]}/fullstaq-ruby.asc" do
      source 'https://raw.githubusercontent.com/fullstaq-labs/fullstaq-ruby-server-edition/master/fullstaq-ruby.asc'
    end

    execute 'add fullstaq repository key' do
      command "apt-key add #{Chef::Config[:file_cache_path]}/fullstaq-ruby.asc"
      user 'root'
    end

    apt_repository 'fullstaq-ruby' do
      uri 'https://apt.fullstaqruby.org'
      distribution "#{node['lsb']['id'].downcase}-#{node['lsb']['release']}"
      components %w[main]
      only_if { node['ruby-provider'] == 'fullstaq' }
    end
  else
    yum_repository 'fullstaq-ruby' do
      baseurl 'https://yum.fullstaqruby.org/centos-7/$basearch'
      enabled true
      gpgcheck false
      gpgkey 'https://raw.githubusercontent.com/fullstaq-labs/fullstaq-ruby-server-edition/master/fullstaq-ruby.asc'
      repo_gpgcheck true
      sslverify true
      only_if { node['ruby-provider'] == 'fullstaq' }
    end
  end

  ruby_package_ver = [node['ruby-version'], node['ruby-variant']].select(&:present?).join('-')
  path = "/usr/lib/fullstaq-ruby/versions/#{ruby_package_ver}/bin:" \
         '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games'

  package "fullstaq-ruby-#{ruby_package_ver}"

  template '/etc/environment' do
    source 'environment.erb'
    mode 0o664
    owner 'root'
    group 'root'
    variables(environment: { 'PATH' => path })
  end

  execute 'update bundler' do
    command "/usr/lib/fullstaq-ruby/versions/#{ruby_package_ver}/bin/gem update bundler"
    user 'root'
    environment('PATH' => path)
  end

  link '/usr/local/bin/bundle' do
    to "/usr/lib/fullstaq-ruby/versions/#{ruby_package_ver}/bin/bundle"
  end
else
  # ruby-ng provider
  if node['platform_family'] == 'debian'
    node.default['ruby-ng']['ruby_version'] = node['ruby-version']
    include_recipe 'ruby-ng::dev'

    link '/usr/local/bin/bundle' do
      to '/usr/bin/bundle'
    end
  else
    ruby_pkg_version = node['ruby-version'].split('.')[0..1]
    package "ruby#{ruby_pkg_version.join('')}"
    package "ruby#{ruby_pkg_version.join('')}-devel"
    execute "/usr/sbin/alternatives --set ruby /usr/bin/ruby#{ruby_pkg_version.join('.')}"

    link '/usr/local/bin/bundle' do
      to '/usr/local/bin/bundler'
    end
  end

  bundler2_applicable = Gem::Requirement.new('>= 3.0.0.beta1').satisfied_by?(
    Gem::Version.new(Gem::VERSION)
  )
  gem_package 'bundler' do
    action :install
    version '~> 1' unless bundler2_applicable
  end
end

apt_repository 'apache2' do
  uri 'http://ppa.launchpad.net/ondrej/apache2/ubuntu'
  distribution node['lsb']['codename']
  components %w[main]
  keyserver 'keyserver.ubuntu.com'
  key 'E5267A6C'
  only_if { node['defaults']['webserver']['use_apache2_ppa'] }
end

apt_repository 'nginx' do
  uri        'http://nginx.org/packages/ubuntu/'
  components ['nginx']
  keyserver 'keyserver.ubuntu.com'
  key 'ABF5BD827BD9BF62'
  only_if { node['defaults']['webserver']['adapter'] == 'nginx' }
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
