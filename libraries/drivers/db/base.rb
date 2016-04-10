# frozen_string_literal: true
module Drivers
  module Db
    class Base < Drivers::Base
      include Drivers::Dsl::Packages
      attr_reader :app, :node, :options

      def initialize(app, node, options = {})
        super
        raise ArgumentError, ':rds option is not set.' unless options[:rds]
        @connection_data_source = validate_engine
      end

      # rubocop:disable Metrics/AbcSize
      def out
        if @connection_data_source == :adapter
          return out_defaults.merge(
            database: out_defaults[:database] || app['data_sources'].first['database_name']
          )
        end

        out_defaults.merge(
          adapter: adapter, username: options[:rds]['db_user'], password: options[:rds]['db_password'],
          host: options[:rds]['address'], database: app['data_sources'].first['database_name']
        )
      end
      # rubocop:enable Metrics/AbcSize

      def out_defaults
        base = JSON.parse(node['deploy'][app['shortname']]['database'].to_json, symbolize_names: true) || {}
        {
          encoding: 'utf8',
          host: 'localhost',
          reconnect: true
        }.merge(base).merge(adapter: adapter)
      end

      def setup(context)
        handle_packages(context)
      end

      def self.allowed_engines(*engines)
        @allowed_engines = engines.map(&:to_s) if engines.present?
        @allowed_engines || []
      end

      def self.adapter(adapter = nil)
        @adapter = adapter if adapter.present?
        (@adapter || self.class.name.underscore).to_s
      end

      protected

      def allowed_engines
        self.class.allowed_engines
      end

      def adapter
        self.class.adapter
      end

      def validate_engine
        rds_engine = options[:rds]['engine']

        return validate_adapter if rds_engine.blank?

        unless allowed_engines.include?(rds_engine)
          raise ArgumentError, "Incorrect :rds engine, expected #{allowed_engines.inspect}, got '#{rds_engine}'."
        end

        :rds
      end

      def validate_adapter
        raise ArgumentError, "Missing :rds engine, expected #{allowed_engines.inspect}." if adapter_engine.blank?
        unless allowed_engines.include?(adapter_engine)
          raise ArgumentError,
                "Incorrect engine provided by adapter, expected #{allowed_engines.inspect}, got '#{adapter_engine}'."
        end

        :adapter
      end

      def adapter_engine
        node['deploy'][app['shortname']]['database'].try(:[], 'adapter')
      end
    end
  end
end
