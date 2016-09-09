# frozen_string_literal: true
module Drivers
  module Appserver
    class Thin < Drivers::Appserver::Base
      adapter :thin
      allowed_engines :thin
      output filter: [:max_connections, :max_persistent_connections, :timeout, :worker_processes]

      def add_appserver_config(context)
        opts = { deploy_dir: deploy_dir(app), out: out, deploy_env: globals[:environment],
                 webserver: Drivers::Webserver::Factory.build(app, node).adapter }

        context.template File.join(opts[:deploy_dir], File.join('shared', 'config', 'thin.yml')) do
          owner node['deployer']['user']
          group www_group
          mode '0644'
          source 'thin.yml.erb'
          variables opts
        end
      end

      def appserver_command(_context)
        'thin -C #{ROOT_PATH}/shared/config/thin.yml'
      end
    end
  end
end
