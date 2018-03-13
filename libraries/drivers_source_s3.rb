# frozen_string_literal: true

module Drivers
  module Source
    class S3 < Drivers::Source::Base
      adapter :s3
      allowed_engines :s3
      packages debian: %w[bzip2 git gzip p7zip tar unzip xz-utils],
               rhel: %w[bzip2 git gzip tar unzip xz]
      output filter: %i[user password url]

      def initialize(context, app, options = {})
        super
        @s3_bucket, @s3_key, @base_url = parse_uri(out[:url])
      end

      def before_deploy
        prepare_archive_directories
        fetch_archive_from_s3
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
          mode '0700'
        end

        context.directory(dummy_repository_dir) do
          mode '0700'
        end
      end

      def fetch_archive_from_s3 # rubocop:disable Metrics/MethodLength
        s3_bucket = @s3_bucket
        s3_key = @s3_key
        base_url = @base_url
        output = out

        context.s3_file File.join(archive_file_dir, s3_key) do
          bucket s3_bucket
          remote_path s3_key
          aws_access_key_id output[:user]
          aws_secret_access_key output[:password]
          owner node['deployer']['user'] || 'root'
          group www_group
          mode '0600'
          s3_url base_url
          action :create
        end
      end

      def prepare_dummy_git_repository
        chef_archive_file_dir = archive_file_dir
        chef_dummy_repository_dir = dummy_repository_dir
        s3_key = @s3_key

        context.ruby_block 'extract' do
          block do
            OpsworksRuby::Archive.new(File.join(chef_archive_file_dir, s3_key)).uncompress(chef_dummy_repository_dir)
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

      # taken from https://github.com/aws/opsworks-cookbooks/blob/release-chef-11.10/scm_helper/libraries/s3.rb#L6
      def parse_uri(uri) # rubocop:disable Metrics/MethodLength
        #                base_uri                |         remote_path
        #----------------------------------------+------------------------------
        # scheme, userinfo, host, port, registry | path, opaque, query, fragment

        components = URI.split(uri)
        base_uri = URI::HTTP.new(*(components.take(5) + [nil] * 4))
        remote_path = URI::HTTP.new(*([nil] * 5 + components.drop(5)))

        virtual_host_match =
          base_uri.host.match(/\A(.+)\.s3(?:[-.](?:ap|eu|sa|us)-(?:.+-)\d|-external-1)?\.amazonaws\.com/i)

        if virtual_host_match
          # virtual-hosted-style: http://bucket.s3.amazonaws.com or http://bucket.s3-aws-region.amazonaws.com
          bucket = virtual_host_match[1]
        else
          # path-style: http://s3.amazonaws.com/bucket or http://s3-aws-region.amazonaws.com/bucket
          uri_path_components = remote_path.path.split('/').reject(&:empty?)
          bucket = uri_path_components.shift # cut first element
          base_uri.path = "/#{bucket}" # append bucket to base_uri
          remote_path.path = uri_path_components.join('/') # delete bucket from remote_path
        end

        # remote_path don't allow a "/" at the beginning
        # base_url don't allow a "/" at the end
        [bucket, remote_path.to_s.to_s.sub(%r{^/}, ''), base_uri.to_s.chomp('/')]
      end
    end
  end
end
