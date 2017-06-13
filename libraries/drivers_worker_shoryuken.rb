# frozen_string_literal: true

module Drivers
  module Worker
    class Shoryuken < Drivers::Worker::Base
      adapter :shoryuken
      allowed_engines :shoryuken
      output filter: %i[config process_count require syslog]
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
        deploy_to = deploy_dir(app)
        config = configuration

        (1..process_count).each do |process_number|
          context.template File.join(deploy_to, File.join('shared', 'config', "shoryuken_#{process_number}.yml")) do
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
          Chef::Log.info("Quiet shoryuken process if exists: #{pid_file}")
          next unless File.file?(pid_file) && pid_exists?(File.open(pid_file).read)
          context.execute "/bin/su - #{node['deployer']['user']} -c 'kill -s USR1 `cat #{pid_file}`'"
        end
      end

      def stop_shoryuken
        (1..process_count).each do |process_number|
          pid_file = pid_file(process_number)
          # Not currently configured
          # timeout = (out[:config]['timeout'] || 8).to_i

          next unless File.file?(pid_file) && pid_exists?(File.open(pid_file).read)

          context.execute(
            "/bin/su - #{node['deployer']['user']} -c 'cd #{File.join(deploy_dir(app), 'current')} && " \
            "#{environment.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')} " \
            "kill -s TERM `cat #{pid_file}`'"
          )
        end
      end

      def pid_file(process_number)
        "#{deploy_dir(app)}/shared/pids/shoryuken_#{app['shortname']}-#{process_number}.pid"
      end

      def pid_exists?(pid)
        Process.getpgid(pid.to_i)
        true
      rescue Errno::ESRCH
        false
      end

      def configuration
        JSON.parse(out[:config].to_json, symbolize_names: true)
      end
    end
  end
end
