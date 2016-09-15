# frozen_string_literal: true
module Drivers
  module Appserver
    class Base < Drivers::Base
      include Drivers::Dsl::Notifies
      include Drivers::Dsl::Output

      def configure(context)
        super
        add_appserver_config(context)
        add_appserver_service_script(context)
        add_appserver_service_context(context)
      end

      def deploy_before_restart(context)
        setup_application_yml(context)
        setup_dot_env(context)
      end

      def after_deploy(context)
        manual_action(context, :stop)
        manual_action(context, :start)
      end
      alias after_undeploy after_deploy

      def out
        handle_output(raw_out)
      end

      def raw_out
        node['defaults']['appserver'].merge(
          node['deploy'][app['shortname']]['appserver'] || {}
        ).symbolize_keys
      end

      def validate_app_engine
      end

      protected

      def appserver_command(_context)
        raise NotImplementedError
      end

      def add_appserver_config(_context)
        raise NotImplementedError
      end

      private

      def manual_action(context, action)
        deploy_to = deploy_dir(app)
        service_script = File.join(deploy_to, File.join('shared', 'scripts', "#{adapter}.service"))

        context.execute "#{action} #{adapter}" do
          command "#{service_script} #{action}"
        end
      end

      def add_appserver_service_script(context)
        opts = { deploy_dir: deploy_dir(app), app_shortname: app['shortname'], deploy_env: globals[:environment],
                 name: adapter, command: appserver_command(context), environment: environment }

        context.template File.join(opts[:deploy_dir], File.join('shared', 'scripts', "#{opts[:name]}.service")) do
          owner node['deployer']['user']
          group www_group
          mode '0755'
          source 'appserver.service.erb'
          variables opts
        end
      end

      def add_appserver_service_context(context)
        deploy_to = deploy_dir(app)
        name = adapter

        context.service "#{name}_#{app['shortname']}" do
          start_command "#{deploy_to}/shared/scripts/#{name}.service start"
          stop_command "#{deploy_to}/shared/scripts/#{name}.service stop"
          restart_command "#{deploy_to}/shared/scripts/#{name}.service restart"
          status_command "#{deploy_to}/shared/scripts/#{name}.service status"
          action :nothing
        end
      end

      def setup_application_yml(context)
        return unless raw_out[:application_yml]
        env_config(context, source_file: 'config/application.yml', destination_file: 'config/application.yml')
      end

      def setup_dot_env(context)
        return unless raw_out[:dot_env]
        env_config(context, source_file: 'dot_env', destination_file: '.env')
      end

      # rubocop:disable Metrics/MethodLength
      def env_config(context, options = { source_file: nil, destination_file: nil })
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
        framework = Drivers::Framework::Factory.build(app, node, options)
        app['environment'].merge(framework.out[:deploy_environment] || {})
      end
    end
  end
end
