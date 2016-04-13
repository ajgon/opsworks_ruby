# frozen_string_literal: true
include_recipe 'opsworks_ruby::configure'

do_migrate = true

every_enabled_application do |app, _deploy|
  scm = Drivers::Scm::Factory.build(app, node)
  scm.before_deploy(self)
  appserver = Drivers::Appserver::Factory.build(app, node)

  deploy app['shortname'] do
    deploy_to deploy_dir(app)
    user node['deployer']['user'] || 'root'
    group www_group

    scm.out.each do |scm_key, scm_value|
      send(scm_key, scm_value)
    end

    appserver.notifies.each do |config|
      notifies config[:action],
               config[:resource].respond_to?(:call) ? config[:resource].call(app) : config[:resource],
               config[:timer]
    end

    migration_command(
      'bundle exec rake db:version > /dev/null 2>&1 && bundle exec rake db:migrate || bundle exec rake db:setup'
    )
    migrate do_migrate
    before_migrate do
      bundle_install File.join(release_path, 'Gemfile') do
        deployment true
        without %w(development test)
      end

      run_callback_from_file(File.join(release_path, 'deploy', 'before_migrate.rb'))
    end

    before_symlink do
      bundle_install File.join(release_path, 'Gemfile') do
        deployment true
        without %w(development test)
      end unless do_migrate

      run_callback_from_file(File.join(release_path, 'deploy', 'before_symlink.rb'))
    end
  end

  scm.after_deploy(self)
end

# every_enabled_app do |app, deploy|
# deploy app['shortname'] do
# deploy_to deploy_dir
# environment app['environment'] || {}
# group www_group
# migrate false
# repository app['app_source']['url']
# rollback_on_error true
# user node['deployer']['user']
# end
# end
