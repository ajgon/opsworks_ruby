# frozen_string_literal: true

module Drivers
  module Appserver
    class Puma < Drivers::Appserver::Base
      adapter :puma
      allowed_engines :puma
      output filter: %i[log_requests preload_app thread_max thread_min timeout worker_processes restart_signal]

      def appserver_config
        'puma.rb'
      end

      def appserver_command
        'puma -C #{ROOT_PATH}/shared/config/puma.rb' # rubocop:disable Lint/InterpolationCheck
      end

      # After deploying, tell Puma to restart instead of doing a stop/start cycle
      def after_deploy
        manual_action('restart')
      end
    end
  end
end
