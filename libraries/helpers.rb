# frozen_string_literal: true

def applications
  if Chef::Config[:solo]
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
  end
  search(:aws_opsworks_app)
end

def rdses
  if Chef::Config[:solo]
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
  end
  search(:aws_opsworks_rds_db_instance)
end

def globals(index, application)
  ag = evaluate_attribute(index, application, :app_global)
  return ag unless ag.nil?

  old_item = old_globals(index, application)
  return old_item unless old_item.nil?
  evaluate_attribute(index, application, :default_global)
end

def evaluate_attribute(index, application, level)
  case level
  when :app_driver
    node['deploy'].try(:[], application).try(:[], driver_type).try(:[], index.to_s)
  when :app_global
    node['deploy'].try(:[], application).try(:[], 'global').try(:[], index.to_s)
  when :default_driver
    node['defaults'].try(:[], driver_type).try(:[], index.to_s)
  when :default_global
    node['defaults'].try(:[], 'global').try(:[], index.to_s)
  end
end

def old_globals(index, application)
  return unless node['deploy'][application][index.to_s]
  message =
    "DEPRECATION WARNING: node['deploy']['#{application}']['#{index}'] is deprecated and will be removed. " \
    "Please use node['deploy']['#{application}']['global']['#{index}'] instead."
  Chef::Log.warn(message)
  STDERR.puts(message)
  node['deploy'][application][index.to_s]
end

def fire_hook(name, options)
  Array.wrap(options[:items]).each do |item|
    old_context = item.context
    item.context = options[:context] if options[:context].present?
    item.send(name)
    item.context = old_context
  end
end

def www_group
  value_for_platform_family(
    'debian' => 'www-data'
  )
end

def create_deploy_dir(application, subdir = '/')
  create_dir File.join(deploy_dir(application), subdir)
end

def create_dir(path)
  directory path do
    mode '0755'
    recursive true
    owner node['deployer']['user'] || 'root'
    group www_group
    not_if { File.directory?(path) }
  end
  path
end

def deploy_dir(application)
  globals('deploy_dir', application['shortname']) || ::File.join('/', 'srv', 'www', application['shortname'])
end

def every_enabled_application
  node['deploy'].each_key do |deploy_app_shortname|
    application = applications.detect { |app| app['shortname'] == deploy_app_shortname }
    next unless application && application['deploy']
    yield application
  end
end

def every_enabled_rds(context, application)
  data = [rdses.presence, Drivers::Db::Factory.build(context, application)].flatten.compact
  data.each do |rds|
    yield rds
  end
end

def perform_bundle_install(shared_path, envs = {})
  bundle_path = "#{shared_path}/vendor/bundle"

  # Check for rbenv in node object
  # If it is set, run bundle install using an rbenv aware script
  # If not, we proceed as normal
  if node['rbenv']
    # Install / initialize an rbenv user with the ruby_version supplied
    # Since the rbenv environment won't persist to library methods, and there are issues with pulling it out into it's own helper, we currently redefine this in multiple places
    # Would be nice to DRY this up if possible

    ruby_version = node['rbenv']['ruby_version']
    deploy_user = node['deployer']['user'] || root

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

    rbenv_script 'bundler update' do
      code "bundle update --bundler"
      user deploy_user
      group www_group
      environment envs
      cwd release_path
    end

    rbenv_script 'bundle install' do
      code "bundle install --deployment -j3 --without development test --path #{bundle_path}"
      user deploy_user
      group www_group
      environment envs
      cwd release_path
    end
  else
    execute 'bundle_update' do
      command "/usr/local/bin/bundle update --bundler"
      user node['deployer']['user'] || 'root'
      group www_group
      environment envs
      cwd release_path
    end

    execute 'bundle_install' do
      command "/usr/local/bin/bundle install --deployment -j3 --without development test --path #{bundle_path}"
      user node['deployer']['user'] || 'root'
      group www_group
      environment envs
      cwd release_path
    end
  end
end

def prepare_recipe
  node.default['deploy'] = Hash[applications.map { |app| [app['shortname'], {}] }].merge(node['deploy'] || {})
  apps_not_included.each do |app_for_removal|
    node.rm('deploy', app_for_removal)
  end
end

def apps_not_included
  return [] if node['applications'].blank?
  node['deploy'].keys.reject { |app_name| node['applications'].include?(app_name) }
end

def enable_mod_passenger_repo(context)
  context.apt_repository 'passenger' do
    uri 'https://oss-binaries.phusionpassenger.com/apt/passenger'
    distribution node['lsb']['codename']
    components %w[main]
    keyserver 'keyserver.ubuntu.com'
    key '561F9B9CAC40B2F7'
  end
end
