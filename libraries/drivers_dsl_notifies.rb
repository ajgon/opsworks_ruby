# frozen_string_literal: true
module Drivers
  module Dsl
    module Notifies
      def self.included(klass)
        klass.instance_eval do
          def notifies(options = {})
            @notifies ||= []
            @notifies.push(options) if options.present?
            @notifies
          end
        end
      end

      def notifies
        self.class.notifies.presence || (self.class.superclass.respond_to?(:notifies) && self.class.superclass.notifies)
      end

      def handle_notifies(out)
        out = out.select { |k, _v| notifies[:filter].include?(k.to_sym) } if notifies[:filter].present?
        out
      end
    end
  end
end
