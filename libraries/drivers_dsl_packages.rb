# frozen_string_literal: true
module Drivers
  module Dsl
    module Packages
      def self.included(klass)
        klass.instance_eval do
          def packages(*to_support)
            @packages = to_support.map(&:to_s) if to_support.present?
            @packages || []
          end
        end
      end

      def packages
        self.class.packages
      end

      def handle_packages(context)
        packages.each do |pkg|
          context.package pkg do
            action :install
          end
        end
      end
    end
  end
end
