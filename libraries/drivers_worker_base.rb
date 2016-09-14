# frozen_string_literal: true
module Drivers
  module Worker
    class Base < Drivers::Base
      include Drivers::Dsl::Output
      include Drivers::Dsl::Packages

      def setup(context)
        handle_packages(context)
      end

      def out
        handle_output(raw_out)
      end

      def raw_out
        node['defaults']['worker'].merge(
          node['deploy'][app['shortname']]['worker'] || {}
        ).symbolize_keys
      end

      def validate_app_engine
      end
    end
  end
end
