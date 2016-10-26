# frozen_string_literal: true

prepare_recipe

every_enabled_application do |application, _app_data|
  databases = []
  every_enabled_rds(self, application) do |rds|
    databases.push(Drivers::Db::Factory.build(self, application, rds: rds))
  end

  scm = Drivers::Scm::Factory.build(self, application)
  framework = Drivers::Framework::Factory.build(self, application, databases: databases)
  appserver = Drivers::Appserver::Factory.build(self, application)
  worker = Drivers::Worker::Factory.build(self, application, databases: databases)
  webserver = Drivers::Webserver::Factory.build(self, application)

  fire_hook(:before_undeploy, items: databases + [scm, framework, appserver, worker, webserver])

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

  fire_hook(:after_undeploy, items: databases + [scm, framework, appserver, worker, webserver])
end
