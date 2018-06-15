# frozen_string_literal: true

module Drivers
  module Appserver
    class Puma < Drivers::Appserver::Base
      adapter :puma
      allowed_engines :puma
      output filter: %i[log_requests preload_app thread_max thread_min timeout
                        on_restart worker_processes before_fork on_worker_boot on_worker_shutdown
                        on_worker_fork after_worker_fork after_deploy port]

      def appserver_config
        'puma.rb'
      end

      def appserver_command
        'puma -C #{ROOT_PATH}/shared/config/puma.rb' # rubocop:disable Lint/InterpolationCheck
      end
    end
  end
end
