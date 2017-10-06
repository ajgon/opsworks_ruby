# frozen_string_literal: true

module Drivers
  module Framework
    class Padrino < Drivers::Framework::Base
      adapter :padrino
      allowed_engines :padrino
      output filter: %i[
        migrate migration_command deploy_environment assets_precompile assets_precompilation_command
      ]

      def settings
        super.merge(
          deploy_environment: { 'RACK_ENV' => deploy_env, 'DATABASE_URL' => database_url },
          assets_precompile: node['deploy'][app['shortname']][driver_type]['assets_precompile']
        )
      end
    end
  end
end
