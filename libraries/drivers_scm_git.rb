# frozen_string_literal: true
module Drivers
  module Scm
    class Git < Drivers::Scm::Base
      adapter Chef::Provider::Git
      allowed_engines :git
      packages :git
      output filter: [:scm_provider, :repository, :revision, :enable_submodules, :ssh_wrapper, :remove_scm_files]
      defaults enable_submodules: true, ssh_wrapper: '/tmp/ssh-git-wrapper.sh'

      def before_deploy(context)
        add_git_wrapper_script(context)
        add_ssh_key(context)
      end

      def after_deploy(context)
        context.file File.join('/', 'tmp', '.ssh-deploy-key') do
          action :delete
        end
      end

      def raw_out
        super.merge(
          ssh_key: app['app_source'].try(:[], 'ssh_key') || node['deploy'][app['shortname']]['scm'].try(:[], 'ssh_key')
        )
      end

      private

      def add_git_wrapper_script(context)
        context.template File.join('/', 'tmp', 'ssh-git-wrapper.sh') do
          source 'ssh-git-wrapper.sh.erb'
          mode '0770'
          owner node['deployer']['user'] || 'root'
          group www_group
        end
      end

      def add_ssh_key(context)
        ssh_key = raw_out[:ssh_key]

        context.template File.join('/', 'tmp', '.ssh-deploy-key') do
          source 'ssh-deploy-key.erb'
          mode '0400'
          owner node['deployer']['user'] || 'root'
          group node['deployer']['group'] || 'root'
          variables ssh_key: ssh_key
        end
      end
    end
  end
end
