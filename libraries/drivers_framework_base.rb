# frozen_string_literal: true
module Drivers
  module Framework
    class Base < Drivers::Base
      include Drivers::Dsl::Output
      include Drivers::Dsl::Packages

      def setup
        handle_packages
      end

      def out
        handle_output(raw_out)
      end

      def raw_out
        node['defaults']['framework'].merge(
          node['deploy'][app['shortname']]['framework'] || {}
        ).symbolize_keys
      end

      def validate_app_engine
      end
    end
  end
end
