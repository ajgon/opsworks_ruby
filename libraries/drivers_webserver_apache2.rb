# frozen_string_literal: true
module Drivers
  module Webserver
    class Apache2 < Drivers::Webserver::Base
      adapter :apache2
      allowed_engines :apache2
      packages debian: 'apache2', rhel: %w(httpd24 mod24_ssl)
      output filter: [
        :dhparams, :keepalive_timeout, :limit_request_body, :log_dir, :log_level, :proxy_timeout,
        :ssl_for_legacy_browsers, :extra_config, :extra_config_ssl
      ]
      notifies :deploy,
               action: :restart, resource: { debian: 'service[apache2]', rhel: 'service[httpd]' }, timer: :delayed
      notifies :undeploy,
               action: :restart, resource: { debian: 'service[apache2]', rhel: 'service[httpd]' }, timer: :delayed

      def raw_out
        output = node['defaults']['webserver'].merge(
          node['deploy'][app['shortname']]['webserver'] || {}
        ).symbolize_keys
        output[:log_dir] = node['deploy'][app['shortname']]['webserver']['log_dir'] || "/var/log/#{service_name}"
        output[:extra_config_ssl] = output[:extra_config] if output[:extra_config_ssl] == true
        output
      end

      def setup
        handle_packages
        enable_modules(%w(expires headers lbmethod_byrequests proxy proxy_balancer proxy_http rewrite ssl))
        add_sites_available_enabled
        define_service(:start)
      end

      def configure
        add_ssl_directory
        add_ssl_item(:private_key)
        add_ssl_item(:certificate)
        add_ssl_item(:chain)
        add_dhparams

        remove_defaults
        add_appserver_config
        enable_appserver_config
      end

      def before_deploy
        define_service
      end
      alias before_undeploy before_deploy

      def conf_dir
        File.join('/', 'etc', node['platform_family'] == 'debian' ? 'apache2' : 'httpd')
      end

      def service_name
        node['platform_family'] == 'debian' ? 'apache2' : 'httpd'
      end

      private

      def remove_defaults
        conf_path = conf_dir

        context.execute 'Remove default sites' do
          command "find #{conf_path}/sites-enabled -maxdepth 1 -mindepth 1 -exec rm -rf {} \\;"
          user 'root'
          group 'root'
        end
      end

      def add_sites_available_enabled
        return if node['platform_family'] == 'debian'

        context.directory "#{conf_dir}/sites-available" do
          mode '0755'
        end
        context.directory "#{conf_dir}/sites-enabled" do
          mode '0755'
        end

        context.execute 'echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf'
      end

      def enable_modules(modules = [])
        return unless node['platform_family'] == 'debian'

        context.execute 'Enable modules' do
          command "a2enmod #{modules.join(' ')}"
          user 'root'
          group 'root'
        end
      end
    end
  end
end
