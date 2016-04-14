# frozen_string_literal: true
module Drivers
  module Framework
    class Rails < Drivers::Framework::Base
      adapter :rails
      allowed_engines :rails
      output filter: [:migrate, :migration_command, :deploy_environment]

      def raw_out
        super.merge(deploy_environment: { 'RAILS_ENV' => 'production' })
      end
    end
  end
end
