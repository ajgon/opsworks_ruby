# frozen_string_literal: true

module Drivers
  module Appserver
    class Base < Drivers::Base
      include Drivers::Dsl::Notifies
      include Drivers::Dsl::Output
      include Drivers::Dsl::Packages

      # Hook function called from the 'setup' recipe.
      def setup
        super
        handle_packages
      end

      def configure
        super
        add_appserver_config
      end

      def before_deploy
        super
        setup_application_yml
        setup_dot_env
      end

      def validate_app_engine; end

      def webserver_config_params
        {}
      end

      protected

      def appserver_command
        raise NotImplementedError
      end

      def appserver_config
        raise NotImplementedError
      end

      # Creates a monit config file for managing the appserver and then notifies
      # monit to reload it.
      def add_appserver_monit
        opts = {
          app_shortname: app['shortname'],
          adapter: adapter,
          appserver_command: appserver_command,
          appserver_name: adapter,
          deploy_to: deploy_dir(app),
          environment: environment,
          source_cookbook: appserver_monit_template_cookbook
        }
        file_path = File.join(node['monit']['basedir'],
                              "#{opts[:appserver_name]}_#{opts[:app_shortname]}.monitrc")
        context.template file_path do
          mode '0640'
          source "#{opts[:adapter]}.monitrc.erb"
          cookbook opts[:source_cookbook].to_s
          variables opts
          notifies :run, 'execute[monit reload]', :immediately
        end
      end

      # Immediately attempts to restart the appserver using monit.
      def restart_monit
        return if ENV['TEST_KITCHEN'] # Don't like it, but we can't run multiple processes in Docker on travis

        context.execute "monit restart #{adapter}_#{app['shortname']}" do
          retries 3
        end
      end

      # If an instance fails to start, the adapter process may not exist
      # and trying to unmonitor it might fail.
      def unmonitor_monit
        context.execute "monit unmonitor #{adapter}_#{app['shortname']}" do
          retries 3
          only_if "monit status | grep -q #{adapter}_#{app['shortname']}"
        end
      end

      # Invoke the monit start command for the appserver. This may only be
      # needed during the initial setup of the instance. After that the
      # 'restart' command is sufficient.
      def start_monit
        context.execute "monit start #{adapter}_#{app['shortname']}" do
          retries 3
        end
      end

      private

      # Overriding the appserver monit configs can be useful to provide more
      # fine-grained control over how the appserver starts, stops and restarts.
      # It can also allow additional configuration to provide alerting.
      #
      # @return [String] configured cookbook to pull custom appserver monit
      #   configs from. Defaults to `opsworks_ruby`.
      def appserver_monit_template_cookbook
        node['deploy'][app['shortname']].try(:[], driver_type).try(:[],
                                                                   'monit_template_cookbook') || context.cookbook_name
      end

      def add_appserver_config
        opts = { deploy_dir: deploy_dir(app), out: out, deploy_env: deploy_env,
                 webserver: Drivers::Webserver::Factory.build(context, app).adapter,
                 appserver_config: appserver_config, app_shortname: app['shortname'] }

        context.template File.join(opts[:deploy_dir], File.join('shared', 'config', opts[:appserver_config])) do
          owner node['deployer']['user']
          group www_group
          mode '0644'
          source "#{opts[:appserver_config]}.erb"
          variables opts
        end
      end

      def setup_application_yml
        return unless raw_out[:application_yml]

        append_to_overwritable_defaults('symlinks', 'config/application.yml' => 'config/application.yml')
        env_config(source_file: 'config/application.yml', destination_file: 'config/application.yml')
      end

      def setup_dot_env
        return unless raw_out[:dot_env]

        append_to_overwritable_defaults('symlinks', 'dot_env' => '.env')
        env_config(source_file: 'dot_env', destination_file: 'dot_env')
      end

      def env_config(options = { source_file: nil, destination_file: nil })
        deploy_to = deploy_dir(app)
        env = environment

        context.template File.join(deploy_to, 'shared', options[:destination_file]) do
          owner node['deployer']['user']
          group www_group
          source "#{File.basename(options[:source_file])}.erb"
          variables environment: env
        end
      end

      def environment
        framework = Drivers::Framework::Factory.build(context, app, options)
        app['environment'].merge(framework.out[:deploy_environment] || {})
                          .merge('HOME' => node['deployer']['home'], 'USER' => node['deployer']['user'])
      end
    end
  end
end
