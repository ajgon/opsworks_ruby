# frozen_string_literal: true

module Drivers
  module Worker
    class Base < Drivers::Base
      include Drivers::Dsl::Output
      include Drivers::Dsl::Packages

      def setup
        super
        handle_packages
      end

      def before_deploy
        super
        setup_dot_env
      end

      def validate_app_engine; end

      protected

      # Adds or updates the monit configs for the worker and notifies monit to
      # reload the configuration.
      # rubocop:disable Metrics/AbcSize
      def add_worker_monit
        opts = {
          adapter: adapter,
          app_shortname: app['shortname'],
          application: app['shortname'],
          deploy_to: deploy_dir(app),
          environment: embed_environment_in_monit? ? environment : { 'RAILS_ENV' => deploy_env },
          name: app['name'],
          out: out,
          source_cookbook: worker_monit_template_cookbook
        }

        context.template File.join(node['monit']['basedir'],
                                   "#{opts[:adapter]}_#{opts[:application]}.monitrc") do
          mode '0640'
          source "#{opts[:adapter]}.monitrc.erb"
          cookbook opts[:source_cookbook].to_s
          variables opts
          notifies :run, 'execute[monit reload]', :immediately
        end
      end
      # rubocop:enable Metrics/AbcSize

      def embed_environment_in_monit?
        !raw_out[:dot_env]
      end

      def setup_dot_env
        return unless raw_out[:dot_env]

        append_to_overwritable_defaults('symlinks', 'dot_env' => '.env')
        env_config(source_file: 'dot_env', destination_file: 'dot_env', environment: environment)
      end

      def worker_monit_template_cookbook
        node['deploy'][app['shortname']][driver_type]['monit_template_cookbook'] || context.cookbook_name
      end

      def restart_monit(pidfile = nil)
        return if ENV['TEST_KITCHEN'] # Don't like it, but we can't run multiple processes in Docker on travis

        @monit_hook = {
          restart: true,
          pidfile: pidfile,
          apps: (1..process_count).to_a.map do |process_number|
            "#{adapter}_#{app['shortname']}-#{process_number}"
          end
        }
      end

      def unmonitor_monit
        (1..process_count).each do |process_number|
          context.execute "monit unmonitor #{adapter}_#{app['shortname']}-#{process_number}" do
            retries 3
          end
        end
      end

      def process_count
        [out[:process_count].to_i, 1].max
      end

      def environment
        framework = Drivers::Framework::Factory.build(context, app, options)
        app['environment'].merge(framework.out[:deploy_environment] || {})
                          .merge('HOME' => node['deployer']['home'], 'USER' => node['deployer']['user'])
      end
    end
  end
end
