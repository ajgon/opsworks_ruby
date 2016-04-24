# frozen_string_literal: true
module Drivers
  module Db
    class Base < Drivers::Base
      include Drivers::Dsl::Defaults
      include Drivers::Dsl::Output
      include Drivers::Dsl::Packages

      defaults encoding: 'utf8', host: 'localhost', reconnect: true

      def initialize(app, node, options = {})
        raise ArgumentError, ':rds option is not set.' unless options[:rds]
        super
      end

      def setup(context)
        handle_packages(context)
      end

      def configure(context)
        database = out
        rails_env = app['attributes']['rails_env']

        context.template File.join(deploy_dir(app), 'shared', 'config', 'database.yml') do
          source 'database.yml.erb'
          mode '0660'
          owner node['deployer']['user'] || 'root'
          group www_group
          variables(database: database, environment: rails_env)
        end
      end

      # rubocop:disable Metrics/AbcSize
      def out
        if configuration_data_source == :node_engine
          return out_defaults.merge(
            database: out_defaults[:database] || app['data_sources'].first['database_name']
          )
        end

        out_defaults.merge(
          adapter: adapter, username: options[:rds]['db_user'], password: options[:rds]['db_password'],
          host: options[:rds]['address'], database: app['data_sources'].first.try(:[], 'database_name')
        )
      end
      # rubocop:enable Metrics/AbcSize

      def out_defaults
        base = JSON.parse((node['deploy'][app['shortname']]['database'] || {}).to_json, symbolize_names: true)
        defaults.merge(base).merge(adapter: adapter)
      end

      protected

      def app_engine
        options[:rds]['engine']
      end

      def node_engine
        node['deploy'][app['shortname']]['database'].try(:[], 'adapter')
      end
    end
  end
end
