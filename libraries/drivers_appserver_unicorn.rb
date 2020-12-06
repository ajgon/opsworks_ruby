# frozen_string_literal: true

module Drivers
  module Appserver
    class Unicorn < Drivers::Appserver::Base
      adapter :unicorn
      allowed_engines :unicorn
      output filter: %i[
        backlog delay preload_app tcp_nodelay tcp_nopush tries timeout worker_processes
        port
      ]
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
        'unicorn.conf'
      end

      def appserver_command
        "bundle exec unicorn_rails --env #{deploy_env} -c #{deploy_dir(app)}/shared/config/unicorn.conf"
      end
    end
  end
end
