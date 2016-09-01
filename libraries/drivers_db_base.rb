# frozen_string_literal: true

module Drivers
  module Db
    class Base < Drivers::Base
      include Drivers::Dsl::Defaults
      include Drivers::Dsl::Output
      include Drivers::Dsl::Packages

      defaults encoding: 'utf8', host: 'localhost', reconnect: true

      def initialize(app, node, options = {})
        super
      end

      def setup(context)
        handle_packages(context)
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def configure(context)
        return unless applicable_for_configuration?

        database = out
        deploy_env = node['deploy'][app['shortname']].try(:[], 'framework').try(:[], 'deploy_env') ||
                     app['attributes']['rails_env']

        context.template File.join(deploy_dir(app), 'shared', 'config', 'database.yml') do
          source 'database.yml.erb'
          mode '0660'
          owner node['deployer']['user'] || 'root'
          group www_group
          variables(database: database, environment: deploy_env)
        end
      end

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
        base = JSON.parse((node['deploy'][app['shortname']]['database'] || {}).to_json, symbolize_names: true)
        defaults.merge(base).merge(adapter: adapter)
      end

      protected

      def app_engine
        options.try(:[], :rds).try(:[], 'engine')
      end

      def node_engine
        node['deploy'][app['shortname']]['database'].try(:[], 'adapter') ||
          node['defaults'].try(:[], 'database').try(:[], 'adapter')
      end

      private

      def applicable_for_configuration?
        configuration_data_source == :node_engine || app['data_sources'].first.blank? || options[:rds].blank? ||
          app['data_sources'].first['arn'] == options[:rds]['rds_db_instance_arn']
      end
    end
  end
end
