# frozen_string_literal: true

module Drivers
  module Webserver
    class Base < Drivers::Base
      include Drivers::Dsl::Logrotate
      include Drivers::Dsl::Notifies
      include Drivers::Dsl::Output
      include Drivers::Dsl::Packages

      def self.passenger_supported?
        false
      end

      def configure
        configure_logrotate
      end

      def out
        handle_output(raw_out)
      end

      def passenger?
        Drivers::Appserver::Factory.build(context, app).adapter == 'passenger'
      end

      def validate_app_engine
        return unless passenger? && !self.class.passenger_supported?
        raise(ArgumentError, "passenger appserver not supported on #{adapter} webserver")
      end

      protected

      def conf_dir
        raise NotImplementedError
      end

      def service_name
        raise NotImplementedError
      end

      def define_service(default_action = :nothing)
        context.service service_name do
          supports status: true, restart: true, reload: true
          action default_action
        end
      end

      def add_ssl_item(name)
        key_data = app[:ssl_configuration].try(:[], name)
        return if key_data.blank?
        extensions = { private_key: 'key', certificate: 'crt', chain: 'ca' }

        context.template "#{conf_dir}/ssl/#{app[:domains].first}.#{extensions[name]}" do
          owner 'root'
          group 'root'
          mode name == :private_key ? '0600' : '0644'
          source 'ssl_key.erb'
          variables key_data: key_data
        end
      end

      def add_ssl_directory
        context.directory "#{conf_dir}/ssl" do
          owner 'root'
          group 'root'
          mode '0700'
        end
      end

      def add_dhparams
        dhparams = out[:dhparams]
        return if dhparams.blank?

        context.template "#{conf_dir}/ssl/#{app[:domains].first}.dhparams.pem" do
          owner 'root'
          group 'root'
          mode '0600'
          source 'ssl_key.erb'
          variables key_data: dhparams
        end
      end

      def add_appserver_config
        a = Drivers::Appserver::Factory.build(context, app)
        opts = { application: app, deploy_dir: deploy_dir(app), out: out, conf_dir: conf_dir, adapter: adapter,
                 name: a.adapter, deploy_env: deploy_env, appserver_config: a.webserver_config_params }
        return unless Drivers::Appserver::Base.adapters.include?(opts[:name])
        generate_appserver_config(opts, site_config_template(opts[:name]), site_config_template_cookbook)
      end

      def generate_appserver_config(opts, source_template, source_cookbook)
        context.template "#{opts[:conf_dir]}/sites-available/#{app['shortname']}.conf" do
          owner 'root'
          group 'root'
          mode '0644'
          source source_template.to_s
          cookbook source_cookbook.to_s
          variables opts
        end
      end

      def enable_appserver_config
        application = app
        conf_path = conf_dir

        context.link "#{conf_path}/sites-enabled/#{application['shortname']}.conf" do
          to "#{conf_path}/sites-available/#{application['shortname']}.conf"
        end
      end

      def site_config_template(appserver_adapter)
        (node['deploy'][app['shortname']][driver_type] || {})['site_config_template'] ||
          node['defaults'][driver_type]['site_config_template'] ||
          appserver_site_config_template(appserver_adapter)
      end

      def appserver_site_config_template(_appserver_adapter)
        "appserver.#{adapter}.conf.erb"
      end

      def site_config_template_cookbook
        (node['deploy'][app['shortname']][driver_type] || {})['site_config_template_cookbook'] ||
          node['defaults'][driver_type]['site_config_template_cookbook'] ||
          context.cookbook_name
      end
    end
  end
end
