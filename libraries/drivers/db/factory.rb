module Drivers
  module Db
    class Factory
      def self.build(app, node, options = {})
        raise ArgumentError, ':rds option is not set.' unless options[:rds]
        engine = Drivers::Db::Base.descendants.detect do |db_driver|
          db_driver.allowed_engines.include?(
            options[:rds]['engine'] || node['deploy'][app['shortname']]['database']['adapter']
          )
        end
        raise StandardError, 'There is no supported Db driver for given configuration.' if engine.blank?
        engine.new(app, node, options)
      end
    end
  end
end
