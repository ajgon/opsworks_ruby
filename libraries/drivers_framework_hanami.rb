# frozen_string_literal: true
module Drivers
  module Framework
    class Hanami < Drivers::Framework::Base
      adapter :hanami
      allowed_engines :hanami
      output filter: [
        :migrate, :migration_command, :deploy_environment, :assets_precompile, :assets_precompilation_command
      ]
      packages debian: 'zlib1g-dev', rhel: 'zlib-devel'

      def raw_out
        assets_command = node['deploy'][app['shortname']]['framework']['assets_precompilation_command'] ||
                         '/usr/local/bin/bundle exec hanami assets precompile'
        migration_command = node['deploy'][app['shortname']]['framework']['migration_command'] ||
                            '/usr/local/bin/bundle exec hanami db migrate'

        super.merge(
          deploy_environment: { 'HANAMI_ENV' => globals[:environment], 'DATABASE_URL' => database_url },
          assets_precompilation_command: assets_command,
          migration_command: migration_command
        )
      end

      def configure
        build_env
      end

      def deploy_before_restart
        link_env
        assets_precompile if out[:assets_precompile]
      end

      private

      def build_env
        deploy_to = deploy_dir(app)
        env = environment

        context.template File.join(deploy_to, 'shared', 'config', ".env.#{globals[:environment]}") do
          owner node['deployer']['user']
          group www_group
          source 'dot_env.erb'
          variables environment: env
        end
      end

      def link_env
        deploy_to = deploy_dir(app)
        env_name = globals[:environment]

        context.link File.join(deploy_to, 'current', ".env.#{env_name}") do
          to File.join(deploy_to, 'shared', 'config', ".env.#{env_name}")
          ignore_failure true
        end
      end

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
        database_url = "sqlite://db/#{app['shortname']}_#{globals[:environment]}.sqlite"

        Array.wrap(options[:databases]).each do |db|
          next unless db.applicable_for_configuration?

          database_url =
            "#{db.out[:adapter]}://#{db.out[:username]}:#{db.out[:password]}@#{db.out[:host]}/#{db.out[:database]}"

          database_url = "sqlite://#{db.out[:database]}" if db.out[:adapter].start_with?('sqlite')
        end

        database_url
      end

      def environment
        app['environment'].merge(out[:deploy_environment])
      end
    end
  end
end
