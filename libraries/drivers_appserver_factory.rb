# frozen_string_literal: true
module Drivers
  module Appserver
    class Factory
      def self.build(app, node, options = {})
        engine = detect_engine(app, node, options)
        raise StandardError, 'There is no supported Appserver driver for given configuration.' if engine.blank?
        engine.new(app, node, options)
      end

      def self.detect_engine(app, node, _options)
        Drivers::Appserver::Base.descendants.detect do |appserver_driver|
          appserver_driver.allowed_engines.include?(
            node['deploy'][app['shortname']]['appserver'].try(:[], 'adapter') ||
            node['defaults']['appserver']['adapter']
          )
        end
      end
    end
  end
end
