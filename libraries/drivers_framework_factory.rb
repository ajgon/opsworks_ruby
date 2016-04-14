# frozen_string_literal: true
module Drivers
  module Framework
    class Factory
      def self.build(app, node, options = {})
        engine = detect_engine(app, node, options)
        raise StandardError, 'There is no supported Framework driver for given configuration.' if engine.blank?
        engine.new(app, node, options)
      end

      def self.detect_engine(app, node, _options)
        Drivers::Framework::Base.descendants.detect do |framework_driver|
          framework_driver.allowed_engines.include?(
            node['deploy'][app['shortname']]['framework'].try(:[], 'adapter') ||
            node['defaults']['framework']['adapter']
          )
        end
      end
    end
  end
end
