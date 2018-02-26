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
          pid_file = pid_file(process_number)
          Chef::Log.info("Quiet Sidekiq process if exists: #{pid_file}")
          next unless File.file?(pid_file) && pid_exists?(File.open(pid_file).read)

          execute_sidekiqctl 'quiet', pid_file
        end
      end

      def stop_sidekiq
        (1..process_count).each do |process_number|
          pid_file = pid_file(process_number)
          timeout = (out[:config]['timeout'] || 8).to_i

          execute_sidekiqctl 'stop', pid_file, timeout
        end
      end

      def pid_file(process_number)
        "/run/lock/#{app['shortname']}/sidekiq_#{app['shortname']}-#{process_number}.pid"
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

      def execute_sidekiqctl(*params)
        if node['rbenv']
          # Install / initialize an rbenv user with the ruby_version supplied
          # Since the rbenv environment won't persist to library methods, and there are issues with pulling it out into it's own helper, we currently redefine this in multiple places
          # Would be nice to DRY this up if possible

          # Install Ruby via rbenv
          ruby_version = node['rbenv']['ruby_version']
          deploy_user = node['deployer']['user'] || root

          # Install rbenv for deploy user
          context.rbenv_user_install(deploy_user)

          # Install a specified ruby_version for deploy user
          context.rbenv_ruby(ruby_version) do
            user(deploy_user)
          end

          # Globally set ruby_version for deploy user
          context.rbenv_global(ruby_version) do
            user(deploy_user)
          end

          context.rbenv_script do
            code "sudo su - #{node['deployer']['user']} -c 'cd #{File.join(deploy_dir(app), 'current')} && " \
                 "#{environment.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')} " \
                 "bundle exec sidekiqctl #{params.map { |param| param.to_s.strip }.join(' ')}'"
            user deploy_user
            cwd File.join(deploy_to, 'current')
            group www_group
            environment env
          end
        else
          context.execute(
            "/bin/su - #{node['deployer']['user']} -c 'cd #{File.join(deploy_dir(app), 'current')} && " \
              "#{environment.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')} " \
              "bundle exec sidekiqctl #{params.map { |param| param.to_s.strip }.join(' ')}'"
          )
        end
      end
    end
  end
end
