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
          deploy_environment: { 'RACK_ENV' => deploy_env, 'DATABASE_URL' => database_url },
          assets_precompile: node['deploy'][app['shortname']]['framework']['assets_precompile']
        )
      end
    end
  end
end
