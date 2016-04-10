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

def www_group
  value_for_platform_family(
    'debian' => 'www-data'
  )
end

def create_deploy_dir(application, subdir = '/')
  subdirs = subdir.split(File::SEPARATOR).select(&:present?)
  (0..(subdirs.length - 1)).each do |i|
    directory File.join(deploy_dir(application), subdirs[0..i]) do
      mode '0755'
      recursive true
      owner node['deployer']['user'] || 'root'
      group www_group
    end
  end
  File.join(deploy_dir(application), subdir)
end

def deploy_dir(application)
  File.join('/', 'srv', 'www', application['shortname'])
end

def every_enabled_application
  node['deploy'].each do |deploy_app_shortname, deploy|
    application = applications.detect { |app| app['shortname'] == deploy_app_shortname }
    next unless application
    deploy = deploy[application['shortname']]
    yield application, deploy
  end
end

def every_enabled_rds
  rdses.each do |rds|
    yield rds
  end
end
