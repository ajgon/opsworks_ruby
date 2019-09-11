# frozen_string_literal: true

class Chef
  class Provider
    class Package < Chef::Provider
      def shell_out_with_timeout!(*command_args)
        command_args[0].gsub!(/--no-rdoc|--no-ri/, '--no-document')
        shell_out!(*add_timeout_option(command_args))
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
