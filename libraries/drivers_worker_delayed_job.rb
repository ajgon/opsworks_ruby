# frozen_string_literal: true
module Drivers
  module Worker
    class DelayedJob < Drivers::Worker::Base
      adapter :delayed_job
      allowed_engines :delayed_job
      output filter: [:process_count, :syslog, :queues]
      packages :monit

      def after_deploy
        restart_monit
      end
      alias after_undeploy after_deploy

      def raw_out
        output = node['defaults']['worker'].merge(
          node['deploy'][app['shortname']]['worker'] || {}
        ).symbolize_keys
        output[:queues] = node['deploy'][app['shortname']]['worker']['queues'] || ''
        output
      end

      def configure
        add_worker_monit
      end
    end
  end
end
