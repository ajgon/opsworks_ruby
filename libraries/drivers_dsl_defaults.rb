# frozen_string_literal: true

module Drivers
  module Dsl
    module Defaults
      def self.included(klass)
        klass.instance_eval do
          def defaults(options = {})
            @defaults = options if options.present?
            @defaults || {}
          end
        end
      end

      def defaults
        self.class.defaults.presence || (self.class.superclass.respond_to?(:defaults) && self.class.superclass.defaults)
      end
    end
  end
end
