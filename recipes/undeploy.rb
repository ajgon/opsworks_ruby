# frozen_string_literal: true

every_enabled_application do |application, _deploy|
  every_enabled_rds do |rds|
    database = Drivers::Db::Factory.build(application, node, rds: rds)
    database.before_undeploy(self)
  end

  scm = Drivers::Scm::Factory.build(application, node)
  framework = Drivers::Framework::Factory.build(application, node)
  appserver = Drivers::Appserver::Factory.build(application, node)
  webserver = Drivers::Webserver::Factory.build(application, node)

  scm.before_undeploy(self)
  framework.before_undeploy(self)
  appserver.before_undeploy(self)
  webserver.before_undeploy(self)

  deploy application['shortname'] do
    deploy_to deploy_dir(application)
    user node['deployer']['user'] || 'root'
    group www_group

    [appserver, webserver].each do |server|
      server.notifies[:undeploy].each do |config|
        notifies config[:action],
                 config[:resource].respond_to?(:call) ? config[:resource].call(application) : config[:resource],
                 config[:timer]
      end
    end

    action :rollback
  end

  scm.after_undeploy(self)
  framework.after_undeploy(self)
  appserver.after_undeploy(self)
  webserver.after_undeploy(self)

  every_enabled_rds do |rds|
    database = Drivers::Db::Factory.build(application, node, rds: rds)
    database.after_undeploy(self)
  end
end
