# frozen_string_literal: true

module Drivers
  module Db
    class Postgresql < Base
      adapter :postgresql
      allowed_engines :postgres, :postgresql, :'aurora-postgresql'
      packages debian: 'libpq-dev', rhel: 'postgresql96-devel'
    end
  end
end
