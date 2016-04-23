# frozen_string_literal: true
module Drivers
  module Db
    class Postgresql < Base
      adapter :postgresql
      allowed_engines :postgres, :postgresql
      packages debian: 'libpq-dev', rhel: 'postgresql94-devel'
    end
  end
end
