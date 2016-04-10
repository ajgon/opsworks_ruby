# frozen_string_literal: true
module Drivers
  module Dsl
    module Output
      def self.included(klass)
        klass.instance_eval do
          def output(options = {})
            @output = options if options.present?
            @output || {}
          end
        end
      end

      def output
        self.class.output.presence || (self.class.superclass.respond_to?(:output) && self.class.superclass.output)
      end

      def handle_output(out)
        out = out.select { |k, _v| output[:filter].include?(k.to_sym) } if output[:filter].present?
        out
      end
    end
  end
end
