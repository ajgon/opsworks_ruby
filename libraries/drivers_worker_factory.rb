# frozen_string_literal: true
module Drivers
  module Worker
    class Factory
      def self.build(context, app, options = {})
        engine = detect_engine(app, context.node, options)
        raise StandardError, 'There is no supported Worker driver for given configuration.' if engine.blank?
        engine.new(context, app, options)
      end

      def self.detect_engine(app, node, _options)
        Drivers::Worker::Base.descendants.detect do |worker_driver|
          worker_driver.allowed_engines.include?(
            node['deploy'][app['shortname']]['worker'].try(:[], 'adapter') ||
            node['defaults']['worker']['adapter']
          )
        end
      end
    end
  end
end
