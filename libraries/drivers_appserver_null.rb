# frozen_string_literal: true
module Drivers
  module Appserver
    class Null < Drivers::Appserver::Base
      adapter :null
      allowed_engines :null
      output filter: []
    end
  end
end
