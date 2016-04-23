# frozen_string_literal: true
module Drivers
  module Dsl
    module Packages
      def self.included(klass)
        klass.instance_eval do
          def packages(*to_support)
            @packages ||= []
            (to_support || []).each do |pkg|
              @packages.push((pkg.is_a?(Hash) ? pkg : { all: pkg.to_s }).stringify_keys)
            end
            @packages.uniq
          end
        end
      end

      def packages
        self.class.packages.presence || (self.class.superclass.respond_to?(:packages) && self.class.superclass.packages)
      end

      def handle_packages(context)
        packages.each do |pkg|
          context.package(pkg.key?('all') ? pkg['all'] : pkg[node['platform_family']] || pkg[node['platform']]) do
            action :install
          end
        end
      end
    end
  end
end
