# frozen_string_literal: true

module Drivers
  module Worker
    class Hutch < Drivers::Worker::Base
      adapter :hutch
      allowed_engines :hutch
      output filter: %i[process_count syslog workers queues]
      packages :monit

      def configure
        add_worker_monit
      end

      def after_deploy
        restart_monit
      end
      alias after_undeploy after_deploy
    end
  end
end
