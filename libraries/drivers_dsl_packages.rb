# frozen_string_literal: true
module Drivers
  module Dsl
    module Packages
      def self.included(klass)
        klass.instance_eval do
          def packages(*to_support)
            @packages ||= {}
            Array.wrap(to_support).each do |pkg|
              @packages = (pkg.is_a?(Hash) ? pkg : { all: Array.wrap(pkg).map(&:to_s) }).stringify_keys
            end
            @packages
          end
        end
      end

      def packages
        self.class.packages.presence || (self.class.superclass.respond_to?(:packages) && self.class.superclass.packages)
      end

      def handle_packages
        Array.wrap(packages['all'] || packages[node['platform_family']] || packages[node['platform']]).each do |pkg|
          context.package pkg do
            action :install
          end
        end
      end
    end
  end
end
