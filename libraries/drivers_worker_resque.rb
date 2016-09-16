# frozen_string_literal: true
module Drivers
  module Worker
    class Resque < Drivers::Worker::Base
      adapter :resque
      allowed_engines :resque
      output filter: [:process_count, :syslog, :workers, :queues]
      packages debian: 'redis-server', rhel: 'redis'

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
