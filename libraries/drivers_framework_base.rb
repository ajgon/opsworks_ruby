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

        # Check for rbenv in node object
        # If it is set, run precompile assets using an rbenv aware script
        # If not, we proceed as normal
        if node['rbenv']
          # Install / initialize an rbenv user with the ruby_version supplied
          # Since the rbenv environment won't persist to library methods, and there are issues with pulling it out into it's own helper, we currently redefine this in multiple places
          # Would be nice to DRY this up if possible

          # Install Ruby via rbenv
          ruby_version = node['rbenv']['ruby_version']
          deploy_user = node['deployer']['user'] || root

          # Install rbenv for deploy user
          context.rbenv_user_install(deploy_user)

          # Install a specified ruby_version for deploy user
          context.rbenv_ruby(ruby_version) do
            user(deploy_user)
          end

          # Globally set ruby_version for deploy user
          context.rbenv_global(ruby_version) do
            user(deploy_user)
          end

          context.rbenv_script 'assets:precompile' do
            code output[:assets_precompilation_command]
            user deploy_user
            cwd File.join(deploy_to, 'current')
            group www_group
            environment env
          end
        else
          context.execute 'assets:precompile' do
            command output[:assets_precompilation_command]
            user node['deployer']['user']
            cwd File.join(deploy_to, 'current')
            group www_group
            environment env
          end
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
