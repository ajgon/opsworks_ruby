# frozen_string_literal: true

module Drivers
  module Db
    class Factory
      def self.build(app, node, options = {})
        engine = detect_engine(app, node, options)
        raise StandardError, 'There is no supported Db driver for given configuration.' if engine.blank?
        engine.new(app, node, options)
      end

      def self.detect_engine(app, node, options)
        Drivers::Db::Base.descendants.detect do |db_driver|
          db_driver.allowed_engines.include?(
            options.try(:[], :rds).try(:[], 'engine') ||
            node.try(:[], 'deploy').try(:[], app['shortname']).try(:[], 'database').try(:[], 'adapter')
          )
        end
      end
    end
  end
end
