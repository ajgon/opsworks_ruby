# frozen_string_literal: true
module Drivers
  module Appserver
    class Unicorn < Drivers::Appserver::Base
      adapter :unicorn
      allowed_engines :unicorn
      output filter: [
        :backlog, :delay, :preload_app, :tcp_nodelay, :tcp_nopush, :tries, :timeout, :worker_processes
      ]

      def appserver_config
        'unicorn.conf'
      end

      def appserver_command
        'unicorn_rails --env #{DEPLOY_ENV} --daemonize -c #{ROOT_PATH}/shared/config/unicorn.conf'
      end
    end
  end
end
