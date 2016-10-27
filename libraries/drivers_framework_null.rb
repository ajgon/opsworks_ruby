# frozen_string_literal: true
module Drivers
  module Framework
    class Null < Drivers::Framework::Base
      adapter :null
      allowed_engines :null
      output filter: [:deploy_environment]

      def raw_out
        super.merge(deploy_environment: { 'RACK_ENV' => deploy_env })
      end
    end
  end
end
