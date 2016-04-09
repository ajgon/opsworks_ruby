module Drivers
  class Base
    def initialize(app, node, options = {})
      @app = app
      @node = node
      @options = options
    end

    # Dummy methods for children to redefine
    def setup
    end

    def configure
    end

    def deploy
    end

    def undeploy
    end

    def shutdown
    end
  end
end
