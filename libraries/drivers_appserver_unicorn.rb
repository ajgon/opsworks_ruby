# frozen_string_literal: true
module Drivers
  module Appserver
    class Unicorn < Drivers::Appserver::Base
      adapter :unicorn
      allowed_engines :unicorn
      output filter: [
        :accept_filter, :backlog, :delay, :preload_app, :tcp_nodelay, :tcp_nopush, :tries, :timeout, :worker_processes
      ]

      def add_appserver_config(context)
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

      def appserver_command(_context)
        'unicorn_rails --env #{DEPLOY_ENV} --daemonize -c #{ROOT_PATH}/shared/config/unicorn.conf'
      end
    end
  end
end
