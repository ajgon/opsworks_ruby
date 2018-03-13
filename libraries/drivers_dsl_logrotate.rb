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
        remove_default_conf
      end

      def remove_default_conf
        context.logrotate_app adapter do
          enable false # option that will soon be deprecated
          action :disable # new option but not working as of this version
        end
      end

      def logrotate_name
        evaluate_attribute('logrotate_name', app['shortname'], :app_driver) ||
          [app['shortname'], adapter, deploy_env].compact.join('-')
      end

      def logrotate_log_paths
        lp = evaluate_attribute('logrotate_log_paths', app['shortname'], :app_driver) || log_paths
        lp.map do |log_path|
          next log_path.call(self) if log_path.is_a?(Proc)
          next log_path if log_path.start_with?('/')
          File.join(deploy_dir(app), log_path)
        end.flatten.uniq
      end

      # rubocop:disable Metrics/AbcSize
      def logrotate_keys
        all_keys =
          (context.node['deploy'][app['shortname']].try(:[], driver_type).try(:keys) || []) +
          (context.node['deploy'][app['shortname']].try(:[], 'global').try(:keys) || []) +
          (context.node['defaults'][driver_type].keys || []) +
          (context.node['defaults']['global'].keys || [])
        all_keys.uniq.map { |k| Regexp.last_match(1) if k =~ /^logrotate_(.+)/ }.compact - %w[name log_paths]
      end
      # rubocop:enable Metrics/AbcSize

      def logrotate_attribute(attribute)
        %i[app_driver app_global default_driver default_global].map do |level|
          evaluate_attribute(attribute, app['shortname'], level)
        end.compact.first
      end

      def logrotate_properties
        Hash[
          logrotate_keys.map do |k|
            lkey = "logrotate_#{k}"
            [k, logrotate_attribute(lkey)]
          end
        ]
      end
    end
  end
end
