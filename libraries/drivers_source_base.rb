# frozen_string_literal: true

module Drivers
  module Source
    class Base < Drivers::Base
      include Drivers::Dsl::Defaults
      include Drivers::Dsl::Packages
      include Drivers::Dsl::Output

      defaults enable_submodules: true

      def setup
        handle_packages
      end

      def fetch(_deploy_context)
        raise NotImplementedError
      end

      def settings
        return default_settings if configuration_data_source == :node_engine

        default_settings.merge(app['app_source'].symbolize_keys)
      end

      def default_settings
        base = node['defaults'][driver_type].merge(
          node['deploy'][app['shortname']][driver_type] || {}
        ).symbolize_keys
        defaults.merge(base)
      end

      protected

      def app_engine
        app['app_source'].try(:[], 'type')
      end

      def node_engine
        node['deploy'][app['shortname']][driver_type].try(:[], 'adapter')
      end
    end
  end
end
