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

      def configure
        super
        add_appserver_monit
      end

      def after_deploy
        super
        restart_monit
        start_monit
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

      # Invoke the monit start command for the appserver. This may only be
      # needed during the initial setup of the instance. After that the
      # 'restart' command is sufficient. If puma is already running this
      # resource will not do anything.
      def start_monit
        pidfile = "/var/run/lock/#{app['shortname']}/puma.pid"
        context.execute "monit start #{adapter}_#{app['shortname']}" do
          retries 3
          creates pidfile
        end
      end

      # Immediately attempts to restart the appserver using monit. Do not
      # attempt a restart if the pid file doesn't exist
      def restart_monit
        return if ENV['TEST_KITCHEN'] # Don't like it, but we can't run multiple processes in Docker on travis

        pidfile = "/var/run/lock/#{app['shortname']}/puma.pid"
        context.execute "monit restart #{adapter}_#{app['shortname']}" do
          retries 3
          only_if { ::File.exist?(pidfile) }
        end
      end

      def appserver_command
        "bundle exec puma -C #{deploy_dir(app)}/shared/config/puma.rb"
      end
    end
  end
end
