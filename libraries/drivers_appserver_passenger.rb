# frozen_string_literal: true

module Drivers
  module Appserver
    class Passenger < Drivers::Appserver::Base
      adapter :passenger
      allowed_engines :passenger
      output filter: %i[max_pool_size min_instances mount_point pool_idle_time max_request_queue_size error_document]

      def manual_action(action); end

      def add_appserver_config; end

      def add_appserver_service_script; end

      def add_appserver_service_context; end

      def webserver_config_params
        o = out
        Hash[%i[max_pool_size min_instances mount_point pool_idle_time max_request_queue_size error_document].map { |k| [k, o[k]] }].reject { |_k, v| v.nil? }
      end
    end
  end
end
