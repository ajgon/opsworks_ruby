# frozen_string_literal: true
module Drivers
  module Webserver
    class Base < Drivers::Base
      include Drivers::Dsl::Notifies
      include Drivers::Dsl::Output

      def out
        handle_output(raw_out)
      end

      def raw_out
        node['defaults']['webserver'].merge(
          node['deploy'][app['shortname']]['webserver'] || {}
        ).symbolize_keys
      end

      def validate_app_engine
      end
    end
  end
end
