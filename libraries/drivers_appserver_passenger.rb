# frozen_string_literal: true

module Drivers
  module Appserver
    class Passenger < Drivers::Appserver::Base
      adapter :passenger
      allowed_engines :passenger
      output filter: %i[mount_point]

      def manual_action(action); end

      def add_appserver_config; end

      def add_appserver_service_script; end
    end
  end
end
