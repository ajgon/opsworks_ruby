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
  globals = (node['deploy'][application].try(:[], 'global') || {}).symbolize_keys
  return globals[index.to_sym] unless globals[index.to_sym].nil?

  old_item = old_globals(index, application)
  return old_item unless old_item.nil?
  node['defaults']['global'][index.to_s]
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
  dir = File.join(deploy_dir(application), subdir)
  directory dir do
    mode '0755'
    recursive true
    owner node['deployer']['user'] || 'root'
    group www_group
    not_if { File.directory?(dir) }
  end
  dir
end

def deploy_dir(application)
  globals('deploy_dir', application['shortname']) || ::File.join('/', 'srv', 'www', application['shortname'])
end

def every_enabled_application
  node['deploy'].keys.each do |deploy_app_shortname|
    application = applications.detect { |app| app['shortname'] == deploy_app_shortname }
    next unless application && application['deploy']
    yield application
  end
end

def every_enabled_rds(context, application)
  data = rdses.presence || [Drivers::Db::Factory.build(context, application)]
  data.each do |rds|
    yield rds
  end
end

def perform_bundle_install(shared_path, envs = {})
  bundle_path = "#{shared_path}/vendor/bundle"

  execute 'bundle_install' do
    command "/usr/local/bin/bundle install --deployment --without development test --path #{bundle_path}"
    user node['deployer']['user'] || 'root'
    group www_group
    environment envs
    cwd release_path
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
