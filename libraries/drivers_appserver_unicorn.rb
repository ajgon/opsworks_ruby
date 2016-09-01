# frozen_string_literal: true
module Drivers
  module Appserver
    class Unicorn < Drivers::Appserver::Base
      adapter :unicorn
      allowed_engines :unicorn
      output filter: [
        :accept_filter, :backlog, :delay, :preload_app, :tcp_nodelay, :tcp_nopush, :tries, :timeout, :worker_processes
      ]

      def configure(context)
        super
        add_unicorn_config(context)
        add_unicorn_service_script(context)
        add_unicorn_service_context(context)
      end

      def after_deploy(context)
        manual_action(context, :stop)
        manual_action(context, :start)
      end
      alias after_undeploy after_deploy

      private

      def manual_action(context, action)
        deploy_to = deploy_dir(app)
        service_script = File.join(deploy_to, File.join('shared', 'scripts', 'unicorn.service'))

        context.execute "#{action} unicorn" do
          command "#{service_script} #{action}"
        end
      end

      def add_unicorn_config(context)
        deploy_to = deploy_dir(app)
        environment = app['environment']
        output = out

        context.template File.join(deploy_to, File.join('shared', 'config', 'unicorn.conf')) do
          owner node['deployer']['user']
          group www_group
          mode '0644'
          source 'unicorn.conf.erb'
          variables environment: environment, deploy_dir: deploy_to, out: output
        end
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def add_unicorn_service_script(context)
        deploy_to = deploy_dir(app)
        app_shortname = app['shortname']
        deploy_env = node['deploy'][app['shortname']].try(:[], 'framework').try(:[], 'deploy_env') ||
                     app['attributes']['rails_env'] || 'production'

        context.template File.join(deploy_to, File.join('shared', 'scripts', 'unicorn.service')) do
          owner node['deployer']['user']
          group www_group
          mode '0755'
          source 'unicorn.service.erb'
          variables app_shortname: app_shortname, deploy_dir: deploy_to, deploy_env: deploy_env
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def add_unicorn_service_context(context)
        deploy_to = deploy_dir(app)

        context.service "unicorn_#{app['shortname']}" do
          start_command "#{deploy_to}/shared/scripts/unicorn.service start"
          stop_command "#{deploy_to}/shared/scripts/unicorn.service stop"
          restart_command "#{deploy_to}/shared/scripts/unicorn.service restart"
          status_command "#{deploy_to}/shared/scripts/unicorn.service status"
          action :nothing
        end
      end
    end
  end
end
