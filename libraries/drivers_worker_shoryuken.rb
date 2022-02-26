# frozen_string_literal: true

module Drivers
  module Worker
    class Shoryuken < Drivers::Worker::Base
      adapter :shoryuken
      allowed_engines :shoryuken
      output filter: %i[config process_count require syslog require_rails]
      packages 'monit'

      def configure
        add_shoryuken_config
        add_worker_monit
      end

      def before_deploy
        quiet_shoryuken
      end

      def after_deploy
        restart_monit
      end

      def shutdown
        quiet_shoryuken
        unmonitor_monit
        stop_shoryuken
      end

      alias after_undeploy after_deploy

      private

      def add_shoryuken_config
        (1..process_count).each do |process_number|
          config = out[:config]
          context.template File.join(deploy_dir(app), 'shared', 'config',
                                     "shoryuken_#{app['shortname']}-#{process_number}.yml") do
            owner node['deployer']['user']
            group www_group
            source 'shoryuken.conf.yml.erb'
            variables config: config
          end
        end
      end

      def quiet_shoryuken
        (1..process_count).each do |process_number|
          pid_file = pid_file(process_number)
          next unless File.file?(pid_file) && pid_exists?(File.read(pid_file))

          Chef::Log.info("Quiet shoryuken process #{pid_file}")
          context.execute "/bin/su - #{node['deployer']['user']} -c 'kill -s USR1 $(cat #{pid_file})'"
        end
      end

      def stop_shoryuken
        (1..process_count).each do |process_number|
          pid_file = pid_file(process_number)

          next unless File.file?(pid_file) && pid_exists?(File.read(pid_file))

          Chef::Log.info("Kill shoryuken process: #{pid_file}")
          context.execute(
            "/bin/su - #{node['deployer']['user']} -c 'cd #{File.join(deploy_dir(app), 'current')} && " \
            "#{environment.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')} " \
            "kill -s TERM $(cat #{pid_file})'"
          )
        end
      end

      # Store pid file in /run/lock, which is usually memory backed and won't persist across reboots
      def pid_file(process_number)
        "/run/lock/shoryuken_#{app['shortname']}-#{process_number}.pid"
      end

      def pid_exists?(pid)
        Process.getpgid(pid.to_i)
        true
      rescue Errno::ESRCH
        false
      end
    end
  end
end
