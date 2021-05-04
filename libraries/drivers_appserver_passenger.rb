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

      def add_appserver_config; end

      def webserver_config_params
        o = out
        # rubocop:disable Style/CollectionCompact
        Hash[WEBSERVER_CONFIG_PARAMS.map { |k| [k, o[k]] }].reject { |_k, v| v.nil? }
        # rubocop:enable Style/CollectionCompact
      end
    end
  end
end
