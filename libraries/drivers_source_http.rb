# frozen_string_literal: true

module Drivers
  module Source
    class Http < Drivers::Source::Base
      adapter :http
      allowed_engines :archive, :http
      packages debian: %w[bzip2 git gzip p7zip tar unzip xz-utils],
               rhel: %w[bzip2 git gzip tar unzip xz]
      output filter: %i[user password url]

      def initialize(context, app, options = {})
        super
        @file_name = File.basename(URI.parse(out[:url]).path)
      end

      def before_deploy
        prepare_archive_directories
        fetch_archive_from_http
        prepare_dummy_git_repository
      end

      def deploy_before_restart
        remove_dot_git
      end

      def fetch(deploy_context)
        deploy_context.repository(dummy_repository_dir)
      end

      private

      def prepare_archive_directories
        context.directory(archive_file_dir) do
          mode '0755'
        end

        context.directory(dummy_repository_dir) do
          mode '0755'
        end
      end

      def fetch_archive_from_http
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

      def prepare_dummy_git_repository
        chef_archive_file_dir = archive_file_dir
        chef_dummy_repository_dir = dummy_repository_dir
        file_name = @file_name

        context.ruby_block 'extract' do
          block do
            OpsworksRuby::Archive.new(File.join(chef_archive_file_dir, file_name)).uncompress(chef_dummy_repository_dir)
          end
        end

        context.execute dummy_git_command
      end

      def remove_dot_git
        context.directory File.join(deploy_dir(app), 'current', '.git') do
          recursive true
          action :delete
        end
      end

      def dummy_git_command
        "cd #{dummy_repository_dir} && git init && git config user.name 'Chef' && " \
        'git config user.email \'chef@localhost\' && git add -A && ' \
        'git commit --author=\'Chef <>\' -m \'dummy repo\' -an'
      end

      def archive_file_dir
        @archive_file_dir ||= File.join(tmpdir, 'archive')
      end

      def dummy_repository_dir
        @dummy_repository_dir ||= File.join(tmpdir, 'archive.d')
      end

      def tmpdir
        return @tmpdir if @tmpdir.present?

        @tmpdir = Dir.mktmpdir('opsworks_ruby')

        context.directory(@tmpdir) do
          mode '0755'
        end

        @tmpdir
      end
    end
  end
end
