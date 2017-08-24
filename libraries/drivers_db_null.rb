# frozen_string_literal: true

module Drivers
  module Db
    class Null < Base
      adapter :null
      allowed_engines :null
      output filter: []
      defaults username: nil, password: nil, host: nil, database: nil

      def can_migrate?
        false
      end
    end
  end
end
