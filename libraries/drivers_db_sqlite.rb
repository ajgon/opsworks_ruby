# frozen_string_literal: true

module Drivers
  module Db
    class Sqlite < Base
      adapter :sqlite3
      allowed_engines :sqlite, :sqlite3
      packages debian: 'libsqlite3-dev', rhel: 'sqlite-devel'

      def out
        output = super
        output[:database] ||= 'db/data.sqlite3'
        handle_output(output)
      end

      def url(deploy_dir)
        "sqlite://#{deploy_dir}/shared/#{out[:database]}"
      end
    end
  end
end
