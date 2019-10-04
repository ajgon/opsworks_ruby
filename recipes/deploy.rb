# frozen_string_literal: true

# Check for rbenv in node object
# If it is set, we migrate using an rbenv aware script
# If not, we proceed as normal
Chef::Provider::Deploy.class_eval do
  def migrate
    run_symlinks_before_migrate

    if new_resource.migrate
      enforce_ownership

      environment = new_resource.environment
      env_info = environment && environment.map do |key_and_val|
        "#{key_and_val.first}='#{key_and_val.last}'"
      end.join(" ")

      converge_by("execute migration command #{new_resource.migration_command}") do

        Chef::Log.info "#{new_resource} migrating #{new_resource.user} with environment #{env_info}"

        # Check for rbenv in node object
        # If it is set, we migrate using an rbenv aware script
        # If not, we proceed as normal
        if node['rbenv']
          # Install / initialize an rbenv user with the ruby_version supplied
          # Since the rbenv environment won't persist to library methods, and there are issues with pulling it out into it's own helper, we currently redefine this in multiple places
          # Would be nice to DRY this up if possible

          # Install Ruby via rbenv
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

          rbenv_script "migration command" do
            code new_resource.migration_command
            user node['deployer']['user'] || 'root'
            group www_group
            environment environment
            cwd release_path
          end
        else
          shell_out!(new_resource.migration_command, run_options(:cwd => release_path, :log_level => :info))
        end
      end
    end
  end
end

prepare_recipe

include_recipe 'opsworks_ruby::configure'

every_enabled_application do |application|
  databases = []
  every_enabled_rds(self, application) do |rds|
    databases.push(Drivers::Db::Factory.build(self, application, rds: rds))
  end

  scm = Drivers::Scm::Factory.build(self, application)
  framework    = Drivers::Framework::Factory.build(self, application, databases: databases)
  appserver    = Drivers::Appserver::Factory.build(self, application)
  worker       = Drivers::Worker::Factory.build(self, application, databases: databases)
  hutch_worker = Drivers::Worker::Hutch.new(self, application, databases: databases)
  webserver    = Drivers::Webserver::Factory.build(self, application)
  bundle_env   = scm.class.adapter.to_s == 'Chef::Provider::Git' ? { 'GIT_SSH' => scm.out[:ssh_wrapper] } : {}

  items = databases + [scm, framework, appserver, worker, webserver]
  items << hutch_worker if node['hutch_server'] && node['hutch_server']['enabled']

  fire_hook(:before_deploy, items: items)

  deploy application['shortname'] do
    deploy_to deploy_dir(application)
    user node['deployer']['user'] || 'root'
    group www_group
    environment application['environment'].merge(framework.out[:deploy_environment] || {})

    if globals(:rollback_on_error, application['shortname']).nil?
      rollback_on_error node['defaults']['global']['rollback_on_error']
    else
      rollback_on_error globals(:rollback_on_error, application['shortname'])
    end

    keep_releases globals(:keep_releases, application['shortname'])
    create_dirs_before_symlink(
      (
        node['defaults']['global']['create_dirs_before_symlink'] +
        Array.wrap(globals(:create_dirs_before_symlink, application['shortname']))
      ).uniq
    )
    purge_before_symlink(
      (
        node['defaults']['global']['purge_before_symlink'] +
        Array.wrap(globals(:purge_before_symlink, application['shortname']))
      ).uniq
    )
    symlink_before_migrate globals(:symlink_before_migrate, application['shortname'])
    symlinks(node['defaults']['global']['symlinks'].merge(globals(:symlinks, application['shortname']) || {}))

    scm.out.each do |scm_key, scm_value|
      send(scm_key, scm_value) if respond_to?(scm_key)
    end

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
      perform_bundle_install(shared_path, bundle_env)

      fire_hook(:deploy_before_migrate, context: self, items: items)

      run_callback_from_file(File.join(release_path, 'deploy', 'before_migrate.rb'))
    end

    before_symlink do
      perform_bundle_install(shared_path, bundle_env) unless framework.migrate?

      fire_hook(:deploy_before_symlink, context: self, items: items)

      run_callback_from_file(File.join(release_path, 'deploy', 'before_symlink.rb'))
    end

    before_restart do
      fire_hook(:deploy_before_restart, context: self, items: items)

      run_callback_from_file(File.join(release_path, 'deploy', 'before_restart.rb'))
    end

    after_restart do
      fire_hook(:deploy_after_restart, context: self, items: items)

      run_callback_from_file(File.join(release_path, 'deploy', 'after_restart.rb'))
    end

    timeout node['deploy']['timeout']
  end

  fire_hook(:after_deploy, items: items)
end
