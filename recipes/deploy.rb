# frozen_string_literal: true

prepare_recipe

include_recipe 'opsworks_ruby::configure'

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
  env_vars = application['environment'].merge(framework.out[:deploy_environment] || {}).merge(
    source.class.adapter.to_s == 'Chef::Provider::Git' ? { 'GIT_SSH' => source.out[:ssh_wrapper] } : {}
  )

  fire_hook(:before_deploy, items: databases + [source, framework, appserver, worker, webserver])

  deploy application['shortname'] do
    deploy_to deploy_dir(application)
    user node['deployer']['user'] || 'root'
    group www_group
    environment env_vars

    provider Chef::Provider::Deploy::Revision if globals(:deploy_revision, application['shortname'])

    if globals(:rollback_on_error, application['shortname']).nil?
      rollback_on_error node['defaults']['global']['rollback_on_error']
    else
      rollback_on_error globals(:rollback_on_error, application['shortname'])
    end

    keep_releases globals(:keep_releases, application['shortname'])
    create_dirs_before_symlink(
      (
        Array.wrap(globals(:create_dirs_before_symlink, application['shortname'])).presence ||
        node['defaults']['global']['create_dirs_before_symlink']
      ).uniq
    )
    purge_before_symlink(
      (
        Array.wrap(globals(:purge_before_symlink, application['shortname'])).presence ||
        node['defaults']['global']['purge_before_symlink']
      ).uniq
    )
    symlink_before_migrate globals(:symlink_before_migrate, application['shortname'])
    symlinks(globals(:symlinks, application['shortname']).presence || node['defaults']['global']['symlinks'])

    source.fetch(self)

    [appserver, webserver].each do |server|
      server.notifies[:deploy].each do |config|
        notifies config[:action],
                 config[:resource].respond_to?(:call) ? config[:resource].call(application) : config[:resource],
                 config[:timer]
      end
    end

    migration_command(framework.out[:migration_command]) if framework.out[:migration_command]
    migrate framework.migrate?
    before_migrate do
      perform_bundle_install(shared_path, env_vars)

      fire_hook(
        :deploy_before_migrate, context: self, items: databases + [source, framework, appserver, worker, webserver]
      )

      run_callback_from_file(File.join(release_path, 'deploy', 'before_migrate.rb'))
    end

    before_symlink do
      perform_bundle_install(shared_path, env_vars) unless framework.migrate?

      fire_hook(
        :deploy_before_symlink, context: self, items: databases + [source, framework, appserver, worker, webserver]
      )

      run_callback_from_file(File.join(release_path, 'deploy', 'before_symlink.rb'))
    end

    before_restart do
      fire_hook(
        :deploy_before_restart, context: self, items: databases + [source, framework, appserver, worker, webserver]
      )

      run_callback_from_file(File.join(release_path, 'deploy', 'before_restart.rb'))
    end

    after_restart do
      fire_hook(
        :deploy_after_restart, context: self, items: databases + [source, framework, appserver, worker, webserver]
      )

      run_callback_from_file(File.join(release_path, 'deploy', 'after_restart.rb'))
    end

    timeout node['deploy']['timeout']
  end

  fire_hook(:after_deploy, items: databases + [source, framework, appserver, worker, webserver])
  handle_monit_hook([appserver, worker, webserver])
end
