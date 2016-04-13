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
        node['defaults']['appserver'].merge(
          node['deploy'][app['shortname']]['appserver'] || {}
        ).symbolize_keys
      end

      def validate_app_engine
      end
    end
  end
end
