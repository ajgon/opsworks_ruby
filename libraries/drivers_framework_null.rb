# frozen_string_literal: true
module Drivers
  module Framework
    class Null < Drivers::Framework::Base
      adapter :null
      allowed_engines :null
      output filter: []
    end
  end
end
