# frozen_string_literal: true

module Drivers
  module Db
    class Base < Drivers::Base
      include Drivers::Dsl::Defaults
      include Drivers::Dsl::Output
      include Drivers::Dsl::Packages

      defaults encoding: 'utf8', host: 'localhost', reconnect: true

      def self.driver_type
        'database'
      end

      def setup
        handle_packages
      end

      # rubocop:disable Metrics/AbcSize:
      def out
        return out_defaults if multiple_databases?
        return out_node_engine if configuration_data_source == :node_engine

        out_defaults.merge(
          adapter: adapter, username: options[:rds]['db_user'], password: options[:rds]['db_password'],
          host: options[:rds]['address'], port: options[:rds]['port'],
          database: app['data_sources'].first.try(:[], 'database_name')
        ).reject { |_k, v| v.blank? }
      end
      # rubocop:enable Metrics/AbcSize:

      def out_node_engine
        out_defaults.merge(
          database: out_defaults[:database] || app['data_sources'].first.try(:[], 'database_name')
        )
      end

      def out_defaults
        base = JSON.parse((driver_config || {}).to_json, symbolize_names: true)
        return base if multiple_databases?

        defaults.merge(base).merge(adapter: adapter)
      end

      def applicable_for_configuration?
        configuration_data_source == :node_engine || app['data_sources'].first.blank? || options[:rds].blank? ||
          app['data_sources'].first['arn'] == options[:rds]['rds_db_instance_arn']
      end

      def can_migrate?
        true
      end

      def url(_deploy_dir)
        show_port = ":#{out[:port]}" unless out[:port].blank?
        "#{out[:adapter]}://#{out[:username]}:#{out[:password]}@#{out[:host]}#{show_port}/#{out[:database]}"
      end

      def multiple_databases?
        (driver_config || {}).values.detect { |child| child.is_a?(Hash) }.present?
      end

      protected

      def app_engine
        options.try(:[], :rds).try(:[], 'engine')
      end

      def node_engine
        adapter = if multiple_databases?
                    driver_config.values.detect { |child| child.is_a?(Hash) }.try(:[], 'adapter')
                  else
                    driver_config.try(:[], 'adapter')
                  end
        adapter || node['defaults'].try(:[], driver_type).try(:[], 'adapter')
      end

      def driver_config
        @driver_config ||= node['deploy'][app['shortname']][driver_type]
      end
    end
  end
end
