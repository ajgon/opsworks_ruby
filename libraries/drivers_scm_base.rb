# frozen_string_literal: true

module Drivers
  module Scm
    class Base < Drivers::Base
      include Drivers::Dsl::Defaults
      include Drivers::Dsl::Packages
      include Drivers::Dsl::Output

      defaults enable_submodules: true

      def setup
        handle_packages
      end

      def out
        handle_output(raw_out)
      end

      def raw_out
        return out_defaults if configuration_data_source == :node_engine
        app_source = app['app_source']

        out_defaults.merge(
          scm_provider: adapter.constantize, repository: app_source['url'], revision: app_source['revision']
        )
      end

      def out_defaults
        base = node['defaults'][driver_type].merge(
          node['deploy'][app['shortname']][driver_type] || {}
        ).symbolize_keys.merge(scm_provider: adapter.constantize)
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
