# frozen_string_literal: true

module Drivers
  module Dsl
    module Notifies
      def self.included(klass)
        klass.instance_eval do
          def notifies(*options)
            @notifies ||= { setup: [], configure: [], deploy: [], undeploy: [], shutdown: [] }
            action = options.shift
            @notifies[action.to_sym].push(options) if options.present?
            @notifies[action.to_sym].flatten!.uniq! if options.present?
            @notifies
          end
        end
      end

      # rubocop:disable Metrics/LineLength
      def notifies
        notifier = self.class.notifies.presence || (self.class.superclass.respond_to?(:notifies) && self.class.superclass.notifies)
        parsed_notifier = {}

        notifier.each_pair do |action, options|
          parsed_notifier[action] = options.map do |option|
            option.merge(
              resource: option[:resource].is_a?(Hash) ? option[:resource][node['platform_family'].to_sym] : option[:resource]
            )
          end
        end

        parsed_notifier
      end
      # rubocop:enable Metrics/LineLength

      def notifying_resource(what, name, action = :restart, timing = :delayed, &block)
        r = context.send(what, name, &block)
        r.notifies(action, "service[#{service_name}]", timing)
        r
      end

      %i[execute file link package template].each do |what|
        define_method "notifying_#{what}" do |name, action = :restart, timing = :delayed, &block|
          notifying_resource(what, name, action, timing, &block)
        end
      end
    end
  end
end
