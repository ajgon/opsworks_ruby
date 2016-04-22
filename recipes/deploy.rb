# frozen_string_literal: true

prepare_recipe

include_recipe 'opsworks_ruby::configure'

every_enabled_application do |application, deploy|
  every_enabled_rds do |rds|
    database = Drivers::Db::Factory.build(application, node, rds: rds)
    database.before_deploy(self)
  end

  scm = Drivers::Scm::Factory.build(application, node)
  framework = Drivers::Framework::Factory.build(application, node)
  appserver = Drivers::Appserver::Factory.build(application, node)
  worker = Drivers::Worker::Factory.build(application, node)
  webserver = Drivers::Webserver::Factory.build(application, node)

  scm.before_deploy(self)
  framework.before_deploy(self)
  appserver.before_deploy(self)
  worker.before_deploy(self)
  webserver.before_deploy(self)

  deploy application['shortname'] do
    deploy_to deploy_dir(application)
    user node['deployer']['user'] || 'root'
    group www_group
    rollback_on_error true
    environment framework.out[:deploy_environment]

    keep_releases deploy[:keep_releases]
    create_dirs_before_symlink(
      (node['defaults']['deploy']['create_dirs_before_symlink'] + Array.wrap(deploy[:create_dirs_before_symlink])).uniq
    )
    purge_before_symlink(
      (node['defaults']['deploy']['purge_before_symlink'] + Array.wrap(deploy[:purge_before_symlink])).uniq
    )
    symlink_before_migrate deploy[:symlink_before_migrate]
    symlinks(node['defaults']['deploy']['symlinks'].merge(deploy[:symlinks] || {}))

    scm.out.each do |scm_key, scm_value|
      send(scm_key, scm_value)
    end

    [appserver, webserver].each do |server|
      server.notifies[:deploy].each do |config|
        notifies config[:action],
                 config[:resource].respond_to?(:call) ? config[:resource].call(application) : config[:resource],
                 config[:timer]
      end
    end

    migration_command(framework.out[:migration_command])
    migrate framework.out[:migrate]
    before_migrate do
      perform_bundle_install(release_path)

      run_callback_from_file(File.join(release_path, 'deploy', 'before_migrate.rb'))
    end

    before_symlink do
      perform_bundle_install(release_path) unless framework.out[:migrate]

      run_callback_from_file(File.join(release_path, 'deploy', 'before_symlink.rb'))
    end

    before_restart do
      directory File.join(release_path, '.git') do
        recursive true
        action :delete
      end

      run_callback_from_file(File.join(release_path, 'deploy', 'before_restart.rb'))
    end
  end

  scm.after_deploy(self)
  framework.after_deploy(self)
  appserver.after_deploy(self)
  worker.after_deploy(self)
  webserver.after_deploy(self)

  every_enabled_rds do |rds|
    database = Drivers::Db::Factory.build(application, node, rds: rds)
    database.after_deploy(self)
  end
end
