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

      def out
        handle_output(raw_out)
      end

      def handle_output(unfiltered)
        if output[:filter]&.is_a?(Array)
          unfiltered.select { |k, _v| output[:filter].include?(k.to_sym) }
        else
          unfiltered
        end
      end

      def raw_out
        settings.each_with_object({}) do |(k, v), hsh|
          hsh[k] = case v
                   when Proc
                     v.call(self, settings)
                   else
                     v
                   end
        end
      end

      def settings
        node['defaults'][driver_type].merge(
          node['deploy'][app['shortname']][driver_type] || {}
        ).symbolize_keys
      end
    end
  end
end
