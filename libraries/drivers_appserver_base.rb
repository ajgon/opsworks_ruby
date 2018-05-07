# frozen_string_literal: true

module Drivers
  module Appserver
    class Base < Drivers::Base
      include Drivers::Dsl::Notifies
      include Drivers::Dsl::Output

      def configure
        super
        add_appserver_config
        add_appserver_service_script
        add_appserver_service_context
      end

      def deploy_before_restart
        setup_application_yml
        setup_dot_env
      end

      def after_deploy
        action = node['deploy'][app['shortname']]['appserver']['after_deploy'] ||
                 node['defaults']['appserver']['after_deploy']
        manual_action(action)
      end
      alias after_undeploy after_deploy

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

      private

      def manual_action(action)
        deploy_to = deploy_dir(app)
        service_script = File.join(deploy_to, File.join('shared', 'scripts', "#{adapter}.service"))

        context.execute "#{action} #{adapter}" do
          command "#{service_script} #{action}"
          live_stream true
        end
      end

      # rubocop:disable Metrics/AbcSize
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
      # rubocop:enable Metrics/AbcSize

      def add_appserver_service_script
        opts = { deploy_dir: deploy_dir(app), app_shortname: app['shortname'], name: adapter, environment: environment,
                 command: appserver_command, deploy_env: deploy_env }

        context.template File.join(opts[:deploy_dir], File.join('shared', 'scripts', "#{opts[:name]}.service")) do
          owner node['deployer']['user']
          group www_group
          mode '0755'
          source 'appserver.service.erb'
          variables opts
        end
      end

      def add_appserver_service_context
        deploy_to = deploy_dir(app)
        name = adapter

        context.service "#{name}_#{app['shortname']}" do
          start_command "#{deploy_to}/shared/scripts/#{name}.service start"
          stop_command "#{deploy_to}/shared/scripts/#{name}.service stop"
          restart_command "#{deploy_to}/shared/scripts/#{name}.service restart"
          status_command "#{deploy_to}/shared/scripts/#{name}.service status"
        end
      end

      def setup_application_yml
        return unless raw_out[:application_yml]
        env_config(source_file: 'config/application.yml', destination_file: 'config/application.yml')
      end

      def setup_dot_env
        return unless raw_out[:dot_env]
        env_config(source_file: 'dot_env', destination_file: '.env')
      end

      # rubocop:disable Metrics/MethodLength
      def env_config(options = { source_file: nil, destination_file: nil })
        deploy_to = deploy_dir(app)
        env = environment

        context.template File.join(deploy_to, 'shared', options[:source_file]) do
          owner node['deployer']['user']
          group www_group
          source "#{File.basename(options[:source_file])}.erb"
          variables environment: env
        end

        context.link File.join(deploy_to, 'current', options[:destination_file]) do
          to File.join(deploy_to, 'shared', options[:source_file])
        end
      end
      # rubocop:enable Metrics/MethodLength

      def environment
        framework = Drivers::Framework::Factory.build(context, app, options)
        app['environment'].merge(framework.out[:deploy_environment] || {})
                          .merge('HOME' => node['deployer']['home'], 'USER' => node['deployer']['user'])
      end
    end
  end
end
