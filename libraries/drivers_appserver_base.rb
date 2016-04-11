# frozen_string_literal: true
module Drivers
  module Appserver
    class Base < Drivers::Base
      include Drivers::Dsl::Notifies
      include Drivers::Dsl::Output

      def out
        handle_output(raw_out)
      end

      def raw_out
        node_engine.symbolize_keys
      end

      protected

      def validate_app_engine
        :node_engine
      end

      def node_engine
        node['appserver']
      end
    end
  end
end
