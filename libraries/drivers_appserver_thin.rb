# frozen_string_literal: true

module Drivers
  module Appserver
    class Thin < Drivers::Appserver::Base
      adapter :thin
      allowed_engines :thin
      output filter: %i[max_connections max_persistent_connections timeout worker_processes
                        port]
      packages 'monit'

      def configure
        super
        add_appserver_monit
      end

      def after_deploy
        super
        restart_monit
      end

      def after_undeploy
        super
        restart_monit
      end

      def shutdown
        unmonitor_monit
      end

      def appserver_config
        'thin.yml'
      end

      def appserver_command
        "bundle exec thin -C #{deploy_dir(app)}/shared/config/thin.yml start"
      end

      def webserver_config_params
        { worker_processes: out[:worker_processes] }
      end
    end
  end
end
