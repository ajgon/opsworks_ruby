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
          (self.class.superclass.respond_to?(:log_paths) && self.class.superclass.log_paths) || []
      end

      def configure_logrotate
        lr_path = logrotate_log_paths || []
        return unless lr_path.any?
        lr_props = logrotate_properties

        context.logrotate_app logrotate_name do
          path   lr_path
          lr_props.each { |k, v| send(k.to_sym, v) unless v.nil? }
        end
      end

      def logrotate_name
        app_global(:logrotate_name, app['shortname']) || "#{app['shortname']}-#{adapter}-#{deploy_env}"
      end

      def logrotate_log_paths
        lp = app_global(:logrotate_log_paths, app['shortname']) || log_paths
        lp.map do |log_path|
          next log_path.call(self) if log_path.is_a?(Proc)
          next log_path if log_path.start_with?('/')
          File.join(deploy_dir(app), log_path)
        end.flatten.uniq
      end

      def logrotate_keys
        all_keys = (context.node['defaults']['global'].keys || []) +
                   (context.node['deploy'][app['shortname']].try(:[], 'global').try(:keys) || [])
        all_keys.uniq.map { |k| Regexp.last_match(1) if k =~ /^logrotate_(.+)/ }.compact - %w[log_paths]
      end

      def logrotate_properties
        Hash[
          logrotate_keys.map do |k|
            lkey = "logrotate_#{k}"
            [k, globals(lkey, app['shortname'])]
          end
        ]
      end
    end
  end
end
