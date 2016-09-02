# frozen_string_literal: true
module Drivers
  module Appserver
    class Puma < Drivers::Appserver::Base
      adapter :puma
      allowed_engines :puma
      output filter: [:log_requests, :preload_app, :thread_max, :thread_min, :timeout, :worker_processes]

      def add_appserver_config(context)
        opts = { environment: app['environment'], deploy_dir: deploy_dir(app), out: out,
                 deploy_env: globals[:environment] }

        context.template File.join(opts[:deploy_dir], File.join('shared', 'config', 'puma.rb')) do
          owner node['deployer']['user']
          group www_group
          mode '0644'
          source 'puma.rb.erb'
          variables opts
        end
      end

      def appserver_command(_context)
        'puma -C #{ROOT_PATH}/shared/config/puma.rb'
      end
    end
  end
end
