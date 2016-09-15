# frozen_string_literal: true
module Drivers
  module Worker
    class DelayedJob < Drivers::Worker::Base
      adapter :delayed_job
      allowed_engines :delayed_job
      output filter: [:process_count, :syslog, :queues]

      def raw_out
        output = node['defaults']['worker'].merge(
          node['deploy'][app['shortname']]['worker'] || {}
        ).symbolize_keys
        output[:queues] = node['deploy'][app['shortname']]['worker']['queues'] || ''
        output
      end

      def configure(context)
        add_delayed_job_monit(context)
      end

      def after_deploy(context)
        (1..process_count).each do |process_number|
          context.execute "monit restart delayed_job_#{app['shortname']}-#{process_number}" do
            retries 3
          end
        end
      end
      alias after_undeploy after_deploy

      private

      def add_delayed_job_monit(context)
        app_shortname = app['shortname']
        deploy_to = deploy_dir(app)
        output = out
        env = environment

        context.template File.join(node['monit']['basedir'], "delayed_job_#{app_shortname}.monitrc") do
          mode '0640'
          source 'delayed_job.monitrc.erb'
          variables application: app_shortname, out: output, deploy_to: deploy_to, environment: env
        end

        context.execute 'monit reload'
      end

      def process_count
        [out[:process_count].to_i, 1].max
      end

      def environment
        framework = Drivers::Framework::Factory.build(app, node, options)
        app['environment'].merge(framework.out[:deploy_environment] || {})
      end
    end
  end
end
