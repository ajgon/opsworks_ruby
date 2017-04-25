# frozen_string_literal: true

module Drivers
  module Dsl
    module Logrotate
      def self.included(klass)
        klass.instance_eval do
          def log_paths(*log_paths)
            @log_paths ||= []
            @log_paths += Array.wrap(log_paths)
            @log_paths
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      def log_paths
        self.class.log_paths.presence ||
          (self.class.superclass.respond_to?(:log_paths) && self.class.superclass.log_paths)
      end

      def configure_logrotate
        return if (log_paths || []).empty?
        lr_path = logrotate_log_paths
        lr_rotate = logrotate_rotate

        context.logrotate_app "#{app['shortname']}-#{adapter}-#{deploy_env}" do
          path lr_path
          frequency 'daily'
          rotate lr_rotate
          options %w[missingok compress delaycompress notifempty copytruncate sharedscripts]
        end
      end

      def logrotate_log_paths
        log_paths.map do |log_path|
          next log_path.call(self) if log_path.is_a?(Proc)
          next log_path if log_path.start_with?('/')
          File.join(deploy_dir(app), log_path)
        end.flatten.uniq
      end

      def logrotate_rotate
        globals(:logrotate_rotate, app['shortname'])
      end
    end
  end
end
