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
        base = node['defaults']['scm'].to_h.symbolize_keys
        base = base.merge(JSON.parse((node['deploy'][app['shortname']]['scm'] || {}).to_json, symbolize_names: true))
        defaults.merge(base).merge(scm_provider: adapter.constantize)
      end

      protected

      def app_engine
        app['app_source'].try(:[], 'type')
      end

      def node_engine
        node['deploy'][app['shortname']]['scm'].try(:[], 'adapter')
      end
    end
  end
end
