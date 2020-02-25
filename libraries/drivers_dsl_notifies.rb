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

      # rubocop:disable Layout/LineLength
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
      # rubocop:enable Layout/LineLength

      def notifying_resource(what, name, action = :restart, timing = :delayed, &block)
        r = context.send(what, name, &block)
        r.notifies(action, "service[#{service_name}]", timing)
        r
      end

      def notifying_execute(name, action = :restart, timing = :delayed, &block)
        notifying_resource(:execute, name, action, timing, &block)
      end

      def notifying_file(name, action = :restart, timing = :delayed, &block)
        notifying_resource(:file, name, action, timing, &block)
      end

      def notifying_link(name, action = :restart, timing = :delayed, &block)
        notifying_resource(:link, name, action, timing, &block)
      end

      def notifying_package(name, action = :restart, timing = :delayed, &block)
        notifying_resource(:package, name, action, timing, &block)
      end

      def notifying_template(name, action = :restart, timing = :delayed, &block)
        notifying_resource(:template, name, action, timing, &block)
      end
    end
  end
end
