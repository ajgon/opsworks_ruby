# frozen_string_literal: true

module Drivers
  module Appserver
    class Puma < Drivers::Appserver::Base
      adapter :puma
      allowed_engines :puma
      output filter: %i[log_requests preload_app thread_max thread_min timeout worker_processes]

      def appserver_config
        'puma.rb'
      end

      def appserver_command
        'puma -C #{ROOT_PATH}/shared/config/puma.rb'
      end
    end
  end
end
