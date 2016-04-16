# frozen_string_literal: true
module Drivers
  module Dsl
    module Notifies
      def self.included(klass)
        klass.instance_eval do
          def notifies(options = {})
            @notifies ||= { setup: [], configure: [], deploy: [], undeploy: [], shutdown: [] }
            action = options.shift
            @notifies[action.to_sym].push(options) if options.present?
            @notifies
          end
        end
      end

      def notifies
        self.class.notifies.presence || (self.class.superclass.respond_to?(:notifies) && self.class.superclass.notifies)
      end
    end
  end
end
