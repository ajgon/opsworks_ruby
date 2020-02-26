# frozen_string_literal: true

class Chef
  class Provider
    class Package < Chef::Provider
      def shell_out_with_timeout!(*command_args)
        command_args[0].gsub!(/--no-rdoc|--no-ri/, '--no-document')
        shell_out!(*add_timeout_option(command_args))
      end
    end

    class Service
      class Debian < Chef::Provider::Service::Init
        # rubocop:disable all
        def get_priority
          priority = {}

          @rcd_status = popen4("/usr/sbin/update-rc.d -f #{current_resource.service_name} remove") do |pid, stdin, stdout, stderr|

            [stdout, stderr].each do |iop|
              iop.each_line do |line|
                if UPDATE_RC_D_PRIORITIES =~ line
                  # priority[runlevel] = [ S|K, priority ]
                  # S = Start, K = Kill
                  # debian runlevels: 0 Halt, 1 Singleuser, 2 Multiuser, 3-5 == 2, 6 Reboot
                  priority[$1] = [($2 == "S" ? :start : :stop), $3]
                end
                if line =~ UPDATE_RC_D_ENABLED_MATCHES
                  enabled = true
                end
              end
            end
          end

          # Reduce existing priority back to an integer if appropriate, picking
          # runlevel 2 as a baseline
          if priority[2] && [2..5].all? { |runlevel| priority[runlevel] == priority[2] }
            priority = priority[2].last
          end

          unless @rcd_status.exitstatus == 0
            @priority_success = false
          end
          priority
        end
        # rubocop:enable all
      end
    end
  end
end

# Taken from: <https://github.com/inopinatus/chef-upgrade>
module CannotSelfTerminate
  def eval_post_install_action
    Chef::Log.info '>>>>>>>>>>>>>>>>>                         <<<<<<<<<<<<<<<<'
    Chef::Log.info '>>>>>>>>>>>>>>>>> I cannot self terminate <<<<<<<<<<<<<<<<'
    Chef::Log.info '>>>>>>>>>>>>>>>>>                         <<<<<<<<<<<<<<<<'
  end
end
