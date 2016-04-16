# frozen_string_literal: true

every_enabled_application do |app, _deploy|
  scm = Drivers::Scm::Factory.build(app, node)
  appserver = Drivers::Appserver::Factory.build(app, node)
  framework = Drivers::Framework::Factory.build(app, node)

  scm.before_undeploy(self)
  appserver.before_undeploy(self)
  framework.before_undeploy(self)

  deploy app['shortname'] do
    deploy_to deploy_dir(app)
    user node['deployer']['user'] || 'root'
    group www_group

    appserver.notifies[:undeploy].each do |config|
      notifies config[:action],
               config[:resource].respond_to?(:call) ? config[:resource].call(app) : config[:resource],
               config[:timer]
    end

    action :rollback
  end

  framework.after_undeploy(self)
  appserver.after_undeploy(self)
  scm.after_undeploy(self)
end
