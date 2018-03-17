# frozen_string_literal: true

module Drivers
  module Source
    module Remote
      class Base < Drivers::Source::Base
        def initialize(context, app, options = {})
          super
          @file_name = File.basename(URI.parse(out[:url]).path)
        end

        def fetch(deploy_context)
          deploy_context.repository(dummy_repository_dir)
        end

        protected

        def before_deploy
          prepare_archive_directories
          fetch_archive_from_remote
          prepare_dummy_git_repository
        end

        def deploy_before_restart
          remove_obsolete_directories
        end

        def prepare_archive_directories
          context.directory(archive_file_dir) do
            mode '0755'
          end

          context.directory(dummy_repository_dir) do
            mode '0755'
          end
        end

        def fetch_archive_from_remote
          raise NotImplementedError
        end

        def prepare_dummy_git_repository
          chef_archive_file_dir = archive_file_dir
          chef_dummy_repository_dir = dummy_repository_dir
          file_name = @file_name

          context.ruby_block 'extract' do
            block do
              OpsworksRuby::Archive.new(File.join(chef_archive_file_dir, file_name))
                                   .uncompress(chef_dummy_repository_dir)
            end
          end

          context.execute dummy_git_command
        end

        def remove_obsolete_directories
          context.directory File.join(deploy_dir(app), 'current', '.git') do
            recursive true
            action :delete
          end

          context.directory tmpdir do
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
end
