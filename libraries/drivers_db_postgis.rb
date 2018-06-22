# frozen_string_literal: true

module Drivers
  module Db
    class Postgis < Base
      adapter :postgis
      allowed_engines :postgis
      packages debian: %w[libpq-dev libgeos-dev], rhel: %w[postgresql96-devel libgeos-devel]
    end
  end
end
