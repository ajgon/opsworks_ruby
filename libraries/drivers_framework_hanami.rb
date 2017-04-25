# frozen_string_literal: true
module Drivers
  module Framework
    class Hanami < Drivers::Framework::Base
      adapter :hanami
      allowed_engines :hanami
      output filter: [
        :migrate, :migration_command, :deploy_environment, :assets_precompile, :assets_precompilation_command
      ]

      def raw_out
        assets_command = node['deploy'][app['shortname']]['framework']['assets_precompilation_command'] ||
                         '/usr/local/bin/bundle exec hanami assets precompile'
        migration_command = node['deploy'][app['shortname']]['framework']['migration_command'] ||
                            '/usr/local/bin/bundle exec hanami db migrate'

        super.merge(
          deploy_environment:
            { 'HANAMI_ENV' => deploy_env, 'DATABASE_URL' => database_url },
          assets_precompilation_command: assets_command,
          migration_command: migration_command
        )
      end

      def configure
        build_env
        super
      end

      def deploy_before_restart
        link_env
        super
      end

      private

      def build_env
        deploy_to = deploy_dir(app)
        env = environment

        context.template File.join(deploy_to, 'shared', 'config', ".env.#{deploy_env}") do
          owner node['deployer']['user']
          group www_group
          source 'dot_env.erb'
          variables environment: env
        end
      end

      def link_env
        deploy_to = deploy_dir(app)
        env_name = deploy_env

        context.link File.join(deploy_to, 'current', ".env.#{env_name}") do
          to File.join(deploy_to, 'shared', 'config', ".env.#{env_name}")
          ignore_failure true
        end
      end
    end
  end
end
