# frozen_string_literal: true
module Drivers
  module Worker
    class Resque < Drivers::Worker::Base
      adapter :resque
      allowed_engines :resque
      output filter: [:process_count, :syslog, :workers, :queues]
      packages debian: 'redis-server', rhel: 'redis'

      def configure(context)
        add_resque_monit(context)
      end

      def after_deploy(context)
        (1..process_count).each do |process_number|
          context.execute "monit restart resque_#{app['shortname']}-#{process_number}" do
            retries 3
          end
        end
      end
      alias after_undeploy after_deploy

      private

      def add_resque_monit(context)
        app_shortname = app['shortname']
        deploy_to = deploy_dir(app)
        output = out
        env = environment

        context.template File.join(node['monit']['basedir'], "resque_#{app_shortname}.monitrc") do
          mode '0640'
          source 'resque.monitrc.erb'
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
