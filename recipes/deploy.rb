# frozen_string_literal: true
include_recipe 'opsworks_ruby::configure'

every_enabled_application do |app, deploy|
  scm = Drivers::Scm::Factory.build(app, node)
  appserver = Drivers::Appserver::Factory.build(app, node)
  framework = Drivers::Framework::Factory.build(app, node)

  scm.before_deploy(self)
  appserver.before_deploy(self)
  framework.before_deploy(self)

  deploy app['shortname'] do
    deploy_to deploy_dir(app)
    user node['deployer']['user'] || 'root'
    group www_group
    rollback_on_error true
    environment framework.out[:deploy_environment]

    create_dirs_before_symlink deploy[:create_dirs_before_symlink]
    keep_releases deploy[:keep_releases]
    purge_before_symlink deploy[:purge_before_symlink] if deploy[:purge_before_symlink]
    symlink_before_migrate deploy[:symlink_before_migrate]
    symlinks deploy[:symlinks] if deploy[:symlinks]

    scm.out.each do |scm_key, scm_value|
      send(scm_key, scm_value)
    end

    appserver.notifies[:deploy].each do |config|
      notifies config[:action],
               config[:resource].respond_to?(:call) ? config[:resource].call(app) : config[:resource],
               config[:timer]
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

  framework.after_deploy(self)
  appserver.after_deploy(self)
  scm.after_deploy(self)
end
