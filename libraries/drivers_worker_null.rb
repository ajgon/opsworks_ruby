# frozen_string_literal: true
module Drivers
  module Worker
    class Null < Drivers::Worker::Base
      adapter :null
      allowed_engines :null
      output filter: []
    end
  end
end
