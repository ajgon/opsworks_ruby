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

      def validate_app_engine; end

      protected

      # Adds or updates the monit configs for the worker and notifies monit to
      # reload the configuration.
      def add_worker_monit
        opts = {
          adapter: adapter,
          app_shortname: app['shortname'],
          application: app['shortname'],
          deploy_to: deploy_dir(app),
          environment: environment,
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

      def worker_monit_template_cookbook
        node['deploy'][app['shortname']][driver_type]['monit_template_cookbook'] || context.cookbook_name
      end

      def restart_monit
        return if ENV['TEST_KITCHEN'] # Don't like it, but we can't run multiple processes in Docker on travis

        (1..process_count).each do |process_number|
          context.execute "monit restart #{adapter}_#{app['shortname']}-#{process_number}" do
            retries 3
          end
        end
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
