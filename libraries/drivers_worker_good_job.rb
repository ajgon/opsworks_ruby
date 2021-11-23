# frozen_string_literal: true

module Drivers
  module Worker
    class GoodJob < Drivers::Worker::Base
      adapter :good_job
      allowed_engines :good_job
      output filter: %i[process_count syslog queues]
      packages :monit

      def after_deploy
        restart_monit
      end
      alias after_undeploy after_deploy

      def settings
        super.merge(queues: node['deploy'][app['shortname']][driver_type]['queues'] || '')
      end

      def configure
        add_worker_monit
      end
    end
  end
end
