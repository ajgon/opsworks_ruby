# frozen_string_literal: true

module Drivers
  module Dsl
    module Packages
      # rubocop:disable Metrics/MethodLength
      def self.included(klass)
        klass.instance_eval do
          def packages(*to_support)
            @packages ||= { 'all' => [], 'debian' => [], 'rhel' => [] }
            Array.wrap(to_support).each { |pkg| add_package(pkg) }
            Hash[@packages.map { |k, v| [k, v.uniq] }]
          end

          def add_package(pkg)
            if pkg.is_a?(Hash)
              pkg = pkg.stringify_keys
              @packages['debian'] += Array.wrap(pkg['debian']).map(&:to_s)
              @packages['rhel'] += Array.wrap(pkg['rhel']).map(&:to_s)
            else
              @packages['all'] += Array.wrap(pkg).map(&:to_s)
            end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      def packages
        self.class.packages.presence || (self.class.superclass.respond_to?(:packages) && self.class.superclass.packages)
      end

      def handle_packages
        to_install =
          (Array.wrap(packages['all']) + Array.wrap(packages[node['platform_family']] || packages[node['platform']]))
        to_install.each do |pkg|
          context.package pkg do
            action :install
          end
        end
      end
    end
  end
end
