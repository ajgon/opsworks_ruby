# frozen_string_literal: true

module Drivers
  module Framework
    class Base < Drivers::Base
      include Drivers::Dsl::Logrotate
      include Drivers::Dsl::Output
      include Drivers::Dsl::Packages

      def setup
        handle_packages
      end

      def configure
        configure_logrotate
      end

      def deploy_before_restart
        assets_precompile if out[:assets_precompile]
      end

      def validate_app_engine; end

      def migrate?
        applicable_databases.any?(&:can_migrate?) && out[:migrate]
      end

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

      def database_url
        deploy_to = deploy_dir(app)
        applicable_databases.first.try(:url, deploy_to)
      end

      def applicable_databases
        dbs = options[:databases] || Drivers::Db::Factory.build(context, app)
        Array.wrap(dbs).select(&:applicable_for_configuration?)
      end

      def environment
        app['environment'].merge(out[:deploy_environment])
      end
    end
  end
end
