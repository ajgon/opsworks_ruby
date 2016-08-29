# frozen_string_literal: true
module Drivers
  module Appserver
    class Base < Drivers::Base
      include Drivers::Dsl::Notifies
      include Drivers::Dsl::Output

      def configure(context)
        application_yml(context)
        dot_env(context)
      end

      def out
        handle_output(raw_out)
      end

      def raw_out
        node['defaults']['appserver'].merge(
          node['deploy'][app['shortname']]['appserver'] || {}
        ).symbolize_keys
      end

      def validate_app_engine
      end

      private

      def application_yml(context)
        return unless raw_out[:application_yml]
        env_config(context, source_file: 'config/application.yml', destination_file: 'config/application.yml')
      end

      def dot_env(context)
        return unless raw_out[:dot_env]
        env_config(context, source_file: 'dot_env', destination_file: '.env')
      end

      # rubocop:disable Metrics/MethodLength
      def env_config(context, options = { source_file: nil, destination_file: nil })
        deploy_to = deploy_dir(app)
        environment = app['environment']

        context.template File.join(deploy_to, 'shared', options[:source_file]) do
          owner node['deployer']['user']
          group www_group
          source "#{File.basename(options[:source_file])}.erb"
          variables environment: environment
        end

        context.link File.join(deploy_to, 'current', options[:destination_file]) do
          to File.join(deploy_to, 'shared', options[:source_file])
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
