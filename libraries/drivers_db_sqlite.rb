# frozen_string_literal: true

module Drivers
  module Db
    class Sqlite < Base
      adapter :sqlite3
      allowed_engines :sqlite, :sqlite3
      packages debian: 'libsqlite3-dev', rhel: 'sqlite-devel'

      def deploy_before_symlink
        link_sqlite_database
      end

      def deploy_before_migrate
        link_sqlite_database
      end

      def validate_node_engine
        populate_node_engine unless node_engine
        :node_engine
      end

      def out
        return handle_output(super) if multiple_databases?

        output = super
        output[:database] ||= 'db/data.sqlite3'
        handle_output(output)
      end

      def url(deploy_dir)
        "sqlite://#{deploy_dir}/shared/#{out[:database]}"
      end

      private

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def link_sqlite_database
        database_configs = multiple_databases? ? out.values : [out]

        database_configs.each do |database_config|
          deploy_to = deploy_dir(app)
          relative_db_path = database_config[:database]
          shared_directory_path = File.join(deploy_to, 'shared', relative_db_path.sub(%r{/[^/]+\.sqlite3?$}, ''))
          release_path = Dir[File.join(deploy_to, 'releases', '*')].last

          context.directory shared_directory_path do
            recursive true
            not_if { ::File.exist?(shared_directory_path) }
          end

          db_path = File.join(deploy_to, 'shared', relative_db_path)
          context.file db_path do
            action :create
            not_if { ::File.exist?(File.join(deploy_to, 'shared', relative_db_path)) }
          end

          context.link File.join(release_path, relative_db_path) do
            to db_path
            not_if { ::File.exist?(::File.join(release_path, relative_db_path)) }
          end
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def populate_node_engine
        framework = Drivers::Framework::Factory.build(context, app)
        deploy = context.node['deploy']
        deploy[app['shortname']][driver_type] ||= {}
        deploy[app['shortname']][driver_type][:database] = "db/#{app['shortname']}_#{framework.deploy_env}.sqlite"
        context.node['deploy'] = deploy
      end
    end
  end
end
