# frozen_string_literal: true
module Drivers
  module Framework
    class Padrino < Drivers::Framework::Base
      adapter :padrino
      allowed_engines :padrino
      output filter: [
        :migrate, :migration_command, :deploy_environment, :assets_precompile, :assets_precompilation_command
      ]

      def raw_out
        super.merge(
          deploy_environment: { 'RACK_ENV' => globals[:environment], 'DATABASE_URL' => database_url },
          assets_precompile: node['deploy'][app['shortname']]['framework']['assets_precompile']
        )
      end

      def deploy_before_restart
        assets_precompile if out[:assets_precompile]
      end

      private

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
    end
  end
end
