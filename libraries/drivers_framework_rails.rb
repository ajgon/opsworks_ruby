# frozen_string_literal: true

module Drivers
  module Framework
    class Rails < Drivers::Framework::Base
      adapter :rails
      allowed_engines :rails
      output filter: %i[
        migrate migration_command deploy_environment assets_precompile assets_precompilation_command
        envs_in_console
      ]
      packages debian: %w[libxml2-dev tzdata zlib1g-dev], rhel: %w[libxml2-devel tzdata zlib-devel]
      log_paths lambda { |context|
        File.join(context.send(:deploy_dir, context.app), 'shared', 'log', '*.log')
      }

      def settings
        super.merge(deploy_environment: { 'RAILS_ENV' => deploy_env })
      end

      def configure
        rdses =
          context.search(:aws_opsworks_rds_db_instance).presence || [Drivers::Db::Factory.build(context, app)]
        rdses.each do |rds|
          database_yml(Drivers::Db::Factory.build(context, app, rds: rds))
        end
        super
      end

      def deploy_after_restart
        setup_rails_console
      end

      private

      def database_yml(db_driver)
        return unless db_driver.applicable_for_configuration? && db_driver.can_migrate?

        database = db_driver.out
        deploy_environment = deploy_env

        context.template File.join(deploy_dir(app), 'shared', 'config', 'database.yml') do
          source 'database.yml.erb'
          mode '0660'
          owner node['deployer']['user'] || 'root'
          group www_group
          variables(database: database, environment: deploy_environment)
        end
      end

      def setup_rails_console
        return unless out[:envs_in_console]
        application_rb_path = File.join(deploy_dir(app), 'current', 'config', 'application.rb')

        return unless File.exist?(application_rb_path)
        env_code = "if(defined?(Rails::Console))\n  " +
                   environment.map { |key, value| "ENV['#{key}'] = #{value.inspect}" }.join("\n  ") +
                   "\nend\n"

        contents = File.read(application_rb_path).sub(/(^(?:module|class).*$)/, "#{env_code}\n\\1")

        File.open(application_rb_path, 'w') { |file| file.write(contents) }
      end

      def environment
        app['environment'].merge(out[:deploy_environment])
      end
    end
  end
end
