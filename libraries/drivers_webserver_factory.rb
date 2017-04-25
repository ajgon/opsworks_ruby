# frozen_string_literal: true

module Drivers
  module Webserver
    class Factory
      def self.build(context, app, options = {})
        engine = detect_engine(app, context.node, options)
        raise StandardError, 'There is no supported Webserver driver for given configuration.' if engine.blank?
        engine.new(context, app, options)
      end

      def self.detect_engine(app, node, _options)
        Drivers::Webserver::Base.descendants.detect do |webserver_driver|
          webserver_driver.allowed_engines.include?(
            node['deploy'][app['shortname']]['webserver'].try(:[], 'adapter') ||
            node['defaults']['webserver']['adapter']
          )
        end
      end
    end
  end
end
