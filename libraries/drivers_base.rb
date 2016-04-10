# frozen_string_literal: true
module Drivers
  class Base
    attr_reader :app, :node, :options, :configuration_data_source
    def initialize(app, node, options = {})
      @app = app
      @node = node
      @options = options
      @configuration_data_source = validate_app_engine
    end

    def self.allowed_engines(*engines)
      @allowed_engines = engines.map(&:to_s) if engines.present?
      @allowed_engines || []
    end

    def self.adapter(adapter = nil)
      @adapter = adapter if adapter.present?
      (@adapter || self.class.name.underscore).to_s
    end

    protected

    def allowed_engines
      self.class.allowed_engines
    end

    def adapter
      self.class.adapter
    end

    # Dummy methods for children to redefine
    def setup(_context)
    end

    def configure(_context)
    end

    def before_deploy(_context)
    end

    def after_deploy(_context)
    end

    def undeploy(_context)
    end

    def shutdown(_context)
    end

    def validate_app_engine
      return validate_node_engine if app_engine.blank?
      validate_engine(:app)
    end

    def validate_node_engine
      raise ArgumentError, "Missing :app or :node engine, expected #{allowed_engines.inspect}." if node_engine.blank?
      validate_engine(:node)
    end

    def validate_engine(type)
      engine_name = "#{type}_engine"
      engine = send(engine_name)
      unless allowed_engines.include?(engine)
        raise ArgumentError, "Incorrect :#{type} engine, expected #{allowed_engines.inspect}, got '#{engine}'."
      end
      engine_name.to_sym
    end

    def app_engine
      raise NotImplementedError
    end

    def node_engine
      raise NotImplementedError
    end
  end
end
