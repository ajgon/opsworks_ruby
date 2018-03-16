# frozen_string_literal: true

module Drivers
  module Source
    module Scm
      class Git < Drivers::Source::Scm::Base
        adapter Chef::Provider::Git
        allowed_engines :git
        packages :git
        output filter: %i[url revision enable_submodules ssh_wrapper remove_scm_files]
        defaults enable_submodules: true,
                 ssh_wrapper: proc { |_driver, settings| settings[:generated_ssh_wrapper] },
                 generated_ssh_wrapper: '/tmp/ssh-git-wrapper.sh'

        def before_deploy
          add_git_wrapper_script
          add_ssh_key
        end

        def deploy_before_restart
          remove_dot_git
        end

        def after_deploy
          context.file File.join('/', 'tmp', '.ssh-deploy-key') do
            action :delete
          end
        end

        def settings
          ssh_key = app['app_source'].try(:[], 'ssh_key') ||
                    node['deploy'][app['shortname']][driver_type].try(:[], 'ssh_key')
          super.merge(ssh_key: ssh_key)
        end

        private

        def add_git_wrapper_script
          return unless raw_out[:ssh_wrapper] == raw_out[:generated_ssh_wrapper]
          context.template raw_out[:generated_ssh_wrapper] do
            source 'ssh-git-wrapper.sh.erb'
            mode '0770'
            owner node['deployer']['user'] || 'root'
            group www_group
          end
        end

        def add_ssh_key
          ssh_key = raw_out[:ssh_key]

          context.template File.join('/', 'tmp', '.ssh-deploy-key') do
            source 'ssh-deploy-key.erb'
            mode '0400'
            owner node['deployer']['user'] || 'root'
            group node['deployer']['group'] || 'root'
            variables ssh_key: ssh_key
          end
        end

        def remove_dot_git
          return unless out[:remove_scm_files]
          context.directory File.join(deploy_dir(app), 'current', '.git') do
            recursive true
            action :delete
          end
        end
      end
    end
  end
end
