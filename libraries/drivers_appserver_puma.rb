# frozen_string_literal: true

module Drivers
  module Appserver
    class Puma < Drivers::Appserver::Base
      adapter :puma
      allowed_engines :puma
      output filter: %i[log_requests preload_app thread_max thread_min timeout
                        on_restart worker_processes before_fork on_worker_boot on_worker_shutdown
                        on_worker_fork after_worker_fork after_deploy port]
      packages 'monit'

      # This is done the first time an instance is setup and then only on demand
      # after that. We need to invoke the monit start script here because puma
      # will not startup if no statefile has been created and the puma 'restart'
      # command won't do that.
      def setup
        super
        add_appserver_monit
        start_monit
      end

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
        'puma.rb'
      end

      def appserver_command
        "bundle exec puma -C #{deploy_dir(app)}/shared/config/puma.rb"
      end
    end
  end
end
