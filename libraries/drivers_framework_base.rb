# frozen_string_literal: true
module Drivers
  module Framework
    class Base < Drivers::Base
      include Drivers::Dsl::Output
      include Drivers::Dsl::Packages

      def setup
        handle_packages
      end

      def deploy_before_migrate
        link_sqlite_database
      end

      def deploy_before_symlink
        link_sqlite_database unless out[:migrate]
      end

      def deploy_before_restart
        assets_precompile if out[:assets_precompile]
      end

      def out
        handle_output(raw_out)
      end

      def raw_out
        node['defaults']['framework'].merge(
          node['deploy'][app['shortname']]['framework'] || {}
        ).symbolize_keys
      end

      def validate_app_engine; end

      protected

      def assets_precompile
        output = out
        deploy_to = deploy_dir(app)
        env = environment.merge('HOME' => node['deployer']['home'])

        context.execute 'assets:precompile' do
          command output[:assets_precompilation_command]
          user node['deployer']['user']
          cwd File.join(deploy_to, 'current')
          group www_group
          environment env
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def link_sqlite_database
        return unless database_url.start_with?('sqlite')
        deploy_to = deploy_dir(app)
        db_path = database_url.sub('sqlite://', '')
        relative_db_path = db_path.sub(deploy_to, '').sub(%r{^/+shared/+}, '')
        release_path = Dir[File.join(deploy_to, 'releases', '*')].last
        shared_directory_path = File.join(deploy_to, 'shared', relative_db_path.sub(%r{/[^/]+\.sqlite3?$}, ''))

        context.directory shared_directory_path do
          recursive true
          not_if { ::File.exist?(shared_directory_path) }
        end

        context.file File.join(deploy_to, 'shared', relative_db_path) do
          action :create
          not_if { ::File.exist?(File.join(deploy_to, 'shared', relative_db_path)) }
        end

        context.link File.join(release_path, relative_db_path) do
          to db_path
          not_if { ::File.exist?(::File.join(release_path, relative_db_path)) }
        end
      end
      # rubocop:enable Metrics/MethodLength

      def database_url
        deploy_to = deploy_dir(app)
        database_url = "sqlite://#{deploy_to}/shared/db/#{app['shortname']}_#{deploy_env}.sqlite"

        Array.wrap(options[:databases]).each do |db|
          next unless db.applicable_for_configuration?

          database_url =
            "#{db.out[:adapter]}://#{db.out[:username]}:#{db.out[:password]}@#{db.out[:host]}/#{db.out[:database]}"

          database_url = "sqlite://#{deploy_to}/shared/#{db.out[:database]}" if db.out[:adapter].start_with?('sqlite')
        end

        database_url
      end
      # rubocop:enable Metrics/AbcSize

      def environment
        app['environment'].merge(out[:deploy_environment])
      end
    end
  end
end
