# frozen_string_literal: true

module Drivers
  module Dsl
    # Generates output for template consumption from OpsWorks Config JSON.
    #
    # Each driver namespace (webserver, appserver, framework etc.) can have it's own set of attributes which can be
    # set in OpsWorks Config JSON - for example: config['deploy']['appname']['webserver']['force_ssl'].
    #
    # To consume, add an output call to the class definition:
    # <tt>
    # class ::Drivers::Webserver::Apache < ::Drivers::Webserver::Base
    #   # Filtering the output contents (recommended).
    #   output filter:  %i[dhparams keepalive_timeout]
    #   # Without filtering the output contents.
    #   output
    # end
    # </tt>
    #
    # Output hashes should only include values that can be configured with JSON.
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
        if output[:filter]&.is_a?(Array) # rubocop:disable Lint/RedundantSafeNavigation
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
