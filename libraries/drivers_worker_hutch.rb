# frozen_string_literal: true

module Drivers
  module Worker
    class Hutch < Drivers::Worker::Base
      adapter(:hutch)
      allowed_engines(:hutch)
      packages(:monit)

      def configure
        add_worker_monit
      end

      def after_deploy
        restart_monit
      end
      alias after_undeploy after_deploy

      def shutdown
        unmonitor_monit
      end

      def process_count
        1
      end
    end
  end
end
