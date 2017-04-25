# frozen_string_literal: true

module Drivers
  class Base
    attr_reader :app, :options, :configuration_data_source
    attr_accessor :context

    def initialize(context, app, options = {})
      @context = context
      @app = app
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

    def self.adapters(options = { include_null: false })
      adapters = descendants.select { |descendant| descendant.respond_to?(:adapter) }.map(&:adapter)
      options[:include_null] ? adapters : adapters - ['null']
    end

    # Dummy methods for children to redefine
    def setup; end

    def configure; end

    def before_deploy; end

    def deploy_before_migrate; end

    def deploy_before_symlink; end

    def deploy_before_restart; end

    def deploy_after_restart; end

    def after_deploy; end

    def before_undeploy; end

    def after_undeploy; end

    def shutdown; end

    protected

    def node
      context.node
    end

    def allowed_engines
      self.class.allowed_engines
    end

    def adapter
      self.class.adapter
    end

    def deploy_env
      globals(:environment, app['shortname'])
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
