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

      def deploy_before_restart(context)
        output = out
        deploy_to = deploy_dir(app)
        env = environment.merge('HOME' => node['deployer']['home'])

        context.execute 'assets:precompile' do
          command output[:assets_precompilation_command]
          user node['deployer']['user']
          cwd File.join(deploy_to, 'current')
          group www_group
          environment env
        end if out[:assets_precompile]
      end

      def deploy_after_restart(context)
        setup_rails_console(context)
      end

      def setup_rails_console(context)
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
