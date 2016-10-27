# frozen_string_literal: true
module Drivers
  module Appserver
    class Null < Drivers::Appserver::Base
      adapter :null
      allowed_engines :null
      output filter: []

      def configure
      end
      alias deploy_before_restart configure
      alias after_deploy configure
      alias after_undeploy configure
    end
  end
end
