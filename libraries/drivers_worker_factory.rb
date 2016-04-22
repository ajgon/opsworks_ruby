# frozen_string_literal: true
module Drivers
  module Worker
    class Factory
      def self.build(app, node, options = {})
        engine = detect_engine(app, node, options)
        raise StandardError, 'There is no supported Worker driver for given configuration.' if engine.blank?
        engine.new(app, node, options)
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
