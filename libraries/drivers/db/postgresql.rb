module Drivers
  module Db
    class Postgresql < Base
      adapter :postgresql
      allowed_engines :postgres, :postgresql
      packages 'libpq-dev'
    end
  end
end
