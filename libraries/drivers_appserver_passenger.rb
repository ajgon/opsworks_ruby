# frozen_string_literal: true

module Drivers
  module Appserver
    class Passenger < Drivers::Appserver::Base
      adapter :passenger
      allowed_engines :passenger
      WEBSERVER_CONFIG_PARAMS = %i[
        max_pool_size
        min_instances
        mount_point
        pool_idle_time
        max_request_queue_size
        error_document
        passenger_max_preloader_idle_time
      ].freeze
      output filter: WEBSERVER_CONFIG_PARAMS

      def manual_action(action); end

      def add_appserver_config; end

      def add_appserver_service_script; end

      def add_appserver_service_context; end

      def webserver_config_params
        o = out
        Hash[WEBSERVER_CONFIG_PARAMS.map { |k| [k, o[k]] }].reject { |_k, v| v.nil? }
      end
    end
  end
end
