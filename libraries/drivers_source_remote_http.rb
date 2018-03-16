# frozen_string_literal: true

module Drivers
  module Source
    module Remote
      class Http < Drivers::Source::Remote::Base
        adapter :http
        allowed_engines :archive, :http
        packages debian: %w[bzip2 git gzip p7zip tar unzip xz-utils],
                 rhel: %w[bzip2 git gzip tar unzip xz]
        output filter: %i[user password url]

        def fetch_archive_from_remote
          uri = URI.parse(out[:url])
          uri.userinfo = "#{out[:user]}:#{out[:password]}"

          context.remote_file File.join(archive_file_dir, @file_name) do
            source uri.to_s
            owner node['deployer']['user'] || 'root'
            group www_group
            mode '0600'
            action :create
          end
        end
      end
    end
  end
end
