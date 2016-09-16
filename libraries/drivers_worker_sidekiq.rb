# frozen_string_literal: true
module Drivers
  module Worker
    class Sidekiq < Drivers::Worker::Base
      adapter :sidekiq
      allowed_engines :sidekiq
      output filter: [:config, :process_count, :require, :syslog]
      packages debian: 'redis-server', rhel: 'redis'

      def configure(context)
        add_sidekiq_config(context)
        add_worker_monit(context)
      end

      def after_deploy(context)
        restart_monit(context)
      end
      alias after_undeploy after_deploy

      private

      def add_sidekiq_config(context)
        deploy_to = deploy_dir(app)
        config = configuration

        (1..process_count).each do |process_number|
          context.template File.join(deploy_to, File.join('shared', 'config', "sidekiq_#{process_number}.yml")) do
            owner node['deployer']['user']
            group www_group
            source 'sidekiq.conf.yml.erb'
            variables config: config
          end
        end
      end

      def configuration
        JSON.parse(out[:config].to_json, symbolize_names: true)
      end
    end
  end
end
