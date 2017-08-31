# frozen_string_literal: true

module Drivers
  module Worker
    class DelayedJob < Drivers::Worker::Base
      adapter :delayed_job
      allowed_engines :delayed_job
      output filter: %i[process_count syslog queues]
      packages :monit

      def after_deploy
        restart_monit
      end
      alias after_undeploy after_deploy

      def raw_out
        super.merge(queues: node['deploy'][app['shortname']][driver_type]['queues'] || '')
      end

      def configure
        add_worker_monit
      end
    end
  end
end
