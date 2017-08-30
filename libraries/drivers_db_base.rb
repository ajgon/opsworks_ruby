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

      # rubocop:disable Metrics/AbcSize
      def out
        if configuration_data_source == :node_engine
          return out_defaults.merge(
            database: out_defaults[:database] || app['data_sources'].first.try(:[], 'database_name')
          )
        end

        out_defaults.merge(
          adapter: adapter, username: options[:rds]['db_user'], password: options[:rds]['db_password'],
          host: options[:rds]['address'], database: app['data_sources'].first.try(:[], 'database_name')
        )
      end
      # rubocop:enable Metrics/AbcSize

      def out_defaults
        base = JSON.parse((node['deploy'][app['shortname']][driver_type] || {}).to_json, symbolize_names: true)
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
        "#{out[:adapter]}://#{out[:username]}:#{out[:password]}@#{out[:host]}/#{out[:database]}"
      end

      protected

      def app_engine
        options.try(:[], :rds).try(:[], 'engine')
      end

      def node_engine
        node['deploy'][app['shortname']][driver_type].try(:[], 'adapter') ||
          node['defaults'].try(:[], driver_type).try(:[], 'adapter')
      end
    end
  end
end
