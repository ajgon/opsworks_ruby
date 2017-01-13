# frozen_string_literal: true
module Drivers
  module Webserver
    class Nginx < Drivers::Webserver::Base
      adapter :nginx
      allowed_engines :nginx
      output filter: [
        :build_type, :client_body_timeout, :client_header_timeout, :client_max_body_size, :dhparams, :keepalive_timeout,
        :log_dir, :log_level, :proxy_read_timeout, :proxy_send_timeout, :send_timeout, :ssl_for_legacy_browsers,
        :extra_config, :extra_config_ssl
      ]
      notifies :deploy, action: :restart, resource: 'service[nginx]', timer: :delayed
      notifies :undeploy, action: :restart, resource: 'service[nginx]', timer: :delayed

      def raw_out
        output = node['defaults']['webserver'].merge(node['nginx']).merge(
          node['deploy'][app['shortname']]['webserver'] || {}
        ).symbolize_keys
        output[:extra_config_ssl] = output[:extra_config] if output[:extra_config_ssl] == true
        output
      end

      def setup
        node.default['nginx']['install_method'] = out[:build_type].to_s == 'source' ? 'source' : 'package'
        recipe = out[:build_type].to_s == 'source' ? 'source' : 'default'
        context.include_recipe("chef_nginx::#{recipe}")
        define_service(:start)
      end

      def configure
        add_ssl_directory
        add_ssl_item(:private_key)
        add_ssl_item(:certificate)
        add_ssl_item(:chain)
        add_dhparams

        add_appserver_config
        enable_appserver_config
      end

      def before_deploy
        define_service
      end
      alias before_undeploy before_deploy

      def conf_dir
        File.join('/', 'etc', 'nginx')
      end

      def service_name
        'nginx'
      end
    end
  end
end
