# frozen_string_literal: true

module Drivers
  module Webserver
    class Null < Drivers::Webserver::Base
      adapter :null
      allowed_engines :null
      output filter: []
    end
  end
end
