# frozen_string_literal: true

module Drivers
  module Appserver
    class Thin < Drivers::Appserver::Base
      adapter :thin
      allowed_engines :thin
      output filter: %i[max_connections max_persistent_connections timeout worker_processes
                        port]

      def appserver_config
        'thin.yml'
      end

      def appserver_command
        'thin -C #{ROOT_PATH}/shared/config/thin.yml' # rubocop:disable Lint/InterpolationCheck
      end
    end
  end
end
