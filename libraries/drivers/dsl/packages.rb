module Drivers
  module Dsl
    module Packages
      include Drivers::Dsl::Base

      param :packages_default_action, default: 'install'
      param :packages, default: []

      def handle_packages
        case packages
        when Array
          if multipackage_supported?
            package packages do
              action packages_default_action.to_sym
            end
          else
            packages.each do |pkg|
              package pkg do
                action packages_default_action.to_sym
              end
            end
          end
        when Hash
          packages.each do |pkg, act|
            package pkg.to_s do
              action act.to_sym
            end
          end
        else
          Chef::Log.warn('`packages` must be an Array or Hash.')
        end
      end
    end
  end
end
