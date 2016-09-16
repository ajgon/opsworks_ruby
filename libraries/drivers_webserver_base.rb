# frozen_string_literal: true
module Drivers
  module Webserver
    class Base < Drivers::Base
      include Drivers::Dsl::Notifies
      include Drivers::Dsl::Output
      include Drivers::Dsl::Packages

      def out
        handle_output(raw_out)
      end

      def raw_out
        node['defaults']['webserver'].merge(
          node['deploy'][app['shortname']]['webserver'] || {}
        ).symbolize_keys
      end

      def validate_app_engine
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
        opts = { application: app, deploy_dir: deploy_dir(app), out: out, conf_dir: conf_dir, adapter: adapter,
                 name: Drivers::Appserver::Factory.build(context, app).adapter }
        return unless Drivers::Appserver::Base.adapters.include?(opts[:name])

        context.template "#{opts[:conf_dir]}/sites-available/#{app['shortname']}.conf" do
          owner 'root'
          group 'root'
          mode '0644'
          source "appserver.#{opts[:adapter]}.conf.erb"
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
    end
  end
end
