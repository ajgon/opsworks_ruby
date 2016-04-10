# frozen_string_literal: true
module Drivers
  class Base
    def initialize(app, node, options = {})
      @app = app
      @node = node
      @options = options
    end

    # Dummy methods for children to redefine
    def setup(_context)
    end

    def configure(_context)
    end

    def deploy(_context)
    end

    def undeploy(_context)
    end

    def shutdown(_context)
    end
  end
end
