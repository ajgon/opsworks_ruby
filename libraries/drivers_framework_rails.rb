# frozen_string_literal: true
module Drivers
  module Framework
    class Rails < Drivers::Framework::Base
      adapter :rails
      allowed_engines :rails
      output filter: [
        :migrate, :migration_command, :deploy_environment, :assets_precompile, :assets_precompilation_command,
        :envs_in_console
      ]
      packages debian: 'zlib1g-dev', rhel: 'zlib-devel'

      def raw_out
        super.merge(deploy_environment: { 'RAILS_ENV' => globals[:environment] })
      end

      def configure
        rdses =
          context.search(:aws_opsworks_rds_db_instance).presence || [Drivers::Db::Factory.build(context, app)]
        rdses.each do |rds|
          database_yml(Drivers::Db::Factory.build(context, app, rds: rds))
        end
      end

      def deploy_before_restart
        assets_precompile if out[:assets_precompile]
      end

      def deploy_after_restart
        setup_rails_console
      end

      private

      def database_yml(db)
        return unless db.applicable_for_configuration?

        database = db.out
        deploy_env = globals[:environment]

        context.template File.join(deploy_dir(app), 'shared', 'config', 'database.yml') do
          source 'database.yml.erb'
          mode '0660'
          owner node['deployer']['user'] || 'root'
          group www_group
          variables(database: database, environment: deploy_env)
        end
      end

      def setup_rails_console
        return unless out[:envs_in_console]
        deploy_to = deploy_dir(app)
        env = environment

        context.template File.join(deploy_to, 'current', 'config', 'initializers', '000_console.rb') do
          owner node['deployer']['user']
          group www_group
          source 'rails_console_overload.rb.erb'
          variables environment: env
        end
      end

      def environment
        app['environment'].merge(out[:deploy_environment])
      end
    end
  end
end
