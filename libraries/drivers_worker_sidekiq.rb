# frozen_string_literal: true
module Drivers
  module Worker
    class Sidekiq < Drivers::Worker::Base
      adapter :sidekiq
      allowed_engines :sidekiq
      output filter: [:config, :process_count, :require, :syslog]
      packages 'monit', debian: 'redis-server', rhel: 'redis'

      def configure
        add_sidekiq_config
        add_worker_monit
      end

      def before_deploy
        quiet_sidekiq
      end

      def after_deploy
        restart_monit
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
        deploy_to = deploy_dir(app)

        (1..process_count).each do |process_number|
          pid_file = "#{deploy_to}/shared/pids/sidekiq_#{process_number}.pid"
          execute "/bin/su - #{node['deployer']['user']} -c 'kill -s USR1 `cat #{pid_file}`'"
        end
      end

      def configuration
        JSON.parse(out[:config].to_json, symbolize_names: true)
      end
    end
  end
end
