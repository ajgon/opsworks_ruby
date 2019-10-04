# frozen_string_literal: true

module Drivers
  module Worker
    class Hutch < Drivers::Worker::Base
      adapter(:hutch)
      allowed_engines(:hutch)
      packages(:monit)

      def configure
        add_worker_monit
      end

      def after_deploy
        restart_monit
      end
      alias after_undeploy after_deploy

      def process_count
        1
      end

      def restart_monit
        return if ENV['TEST_KITCHEN'] # Don't like it, but we can't run multiple processes in Docker on travis

        context.execute "monit restart hutch_#{app['shortname']}_worker" do
          retries 3
        end
      end

      def add_worker_monit
        opts = {
          application:      app['shortname'],
          out:              out,
          deploy_to:        deploy_dir(app),
          environment:      environment,
          adapter:          adapter,
          app_shortname:    app['shortname'],
          hutch_identifier: hutch_identifier,
          hutch_pid_file:   hutch_pid_file,
          executing_user:   user
        }

        context.template File.join(node['monit']['basedir'], "#{opts[:adapter]}_#{opts[:application]}.monitrc") do
          mode('0640')
          source("#{opts[:adapter]}.monitrc.erb")
          variables(opts)
        end

        context.execute 'monit reload'
      end

      private

      def hutch_identifier
        "hutch_#{app['shortname']}_worker"
      end

      def hutch_pid_file
        "/run/lock/#{app['shortname']}/#{hutch_identifier}.pid"
      end

      def executing_user
        node['deployer']['user'] || context.root
      end

      def hutch_shell_cmd
        env_info = environment.map {|k,v| "#{k}=\"#{v}\""}.join(' ')
        "#{env_info} bundle exec hutch --autoload-rails --pidfile=#{hutch_pid_file}"
      end
    end
  end
end
