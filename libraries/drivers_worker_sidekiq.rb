# frozen_string_literal: true

module Drivers
  module Worker
    class Sidekiq < Drivers::Worker::Base
      adapter :sidekiq
      allowed_engines :sidekiq
      output filter: %i[config process_count require syslog]
      packages 'monit', debian: 'redis-server', rhel: 'redis'

      def configure
        add_sidekiq_config
        add_worker_monit
      end

      def before_deploy
        super
        quiet_sidekiq
      end

      def after_deploy
        restart_monit
      end

      def shutdown
        quiet_sidekiq
        unmonitor_monit
        stop_sidekiq
      end

      alias after_undeploy after_deploy

      private

      def add_sidekiq_config
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

      def quiet_sidekiq
        (1..process_count).each do |process_number|
          Chef::Log.info("Quiet Sidekiq process if exists: no. #{process_number}")

          context.execute(send_signal_to_sidekiq(process_number, :TSTP))
        end
      end

      def stop_sidekiq
        (1..process_count).each do |process_number|
          timeout = (out[:config]['timeout'] || 8).to_i
          Chef::Log.info("Stop Sidekiq process if exists: no. #{process_number}")

          context.execute("timeout #{timeout} #{send_signal_to_sidekiq(process_number)}")
        end
      end

      def send_signal_to_sidekiq(process_number, signal = nil)
        "/bin/su - #{node['deployer']['user']} -c \"ps -ax | grep 'bundle exec sidekiq' | " \
          "grep sidekiq_#{process_number}.yml | grep -v grep | awk '{print \\$1}' | " \
          "xargs --no-run-if-empty pgrep -P | xargs --no-run-if-empty kill#{" -#{signal}" if signal}\""
      end

      def configuration
        JSON.parse(out[:config].to_json, symbolize_names: true)
      end
    end
  end
end
