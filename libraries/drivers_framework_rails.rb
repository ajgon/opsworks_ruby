# frozen_string_literal: true
module Drivers
  module Framework
    class Rails < Drivers::Framework::Base
      adapter :rails
      allowed_engines :rails
      output filter: [
        :migrate, :migration_command, :deploy_environment, :assets_precompile, :assets_precompilation_command
      ]
      packages debian: 'zlib1g-dev', rhel: 'zlib-devel'

      def raw_out
        super.merge(deploy_environment: { 'RAILS_ENV' => 'production' })
      end

      def after_deploy(context)
        output = out
        deploy_to = deploy_dir(app)
        env = environment

        context.execute 'assets:precompile' do
          command output[:assets_precompilation_command]
          user node['deployer']['user']
          cwd File.join(deploy_to, 'current')
          group www_group
          environment env
        end if out[:assets_precompile]
      end

      def environment
        app['environment'].merge(out[:deploy_environment])
      end
    end
  end
end
