# frozen_string_literal: true
module Drivers
  module Worker
    class Sidekiq < Drivers::Worker::Base
      adapter :sidekiq
      allowed_engines :sidekiq
      output filter: [:config, :process_count, :require, :syslog]

      def configure(context)
        add_sidekiq_config(context)
        add_sidekiq_monit(context)
      end

      def after_deploy(context)
        context.execute 'monit reload'
        (1..process_count).each do |process_number|
          context.execute "monit restart sidekiq_#{app['shortname']}-#{process_number}" do
            retries 3
          end
        end
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

      def add_sidekiq_monit(context)
        app_shortname = app['shortname']
        deploy_to = deploy_dir(app)
        output = out
        env = environment

        context.template File.join('/', 'etc', 'monit', 'conf.d', "sidekiq_#{app_shortname}.monitrc") do
          mode '0640'
          source 'sidekiq.monitrc.erb'
          variables application: app_shortname, out: output, deploy_to: deploy_to, environment: env
        end
      end

      def process_count
        [out[:process_count].to_i, 1].max
      end

      def environment
        framework = Drivers::Framework::Factory.build(app, node)
        app['environment'].merge(framework.out[:deploy_environment] || {})
      end

      def configuration
        JSON.parse(out[:config].to_json, symbolize_names: true)
      end
    end
  end
end
