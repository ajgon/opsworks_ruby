module Drivers
  module Dsl
    module Base
      @@params = {}

      def self.included(klass)
        klass.instance_eval do
          def param(name, options = {})
            name = name.to_sym
            @@params[name] = options[:default]
            send(:define_method, name) do |*values|
              @@params[name] = options[:default].is_a?(Array) ? values : values.first unless values.empty?
              @@params[name]
            end
          end
        end
      end
    end
  end
end

