# frozen_string_literal: true

prepare_recipe

every_enabled_application do |application, _deploy|
  databases = []
  every_enabled_rds(application) do |rds|
    databases.push(Drivers::Db::Factory.build(application, node, rds: rds))
  end

  scm = Drivers::Scm::Factory.build(application, node)
  framework = Drivers::Framework::Factory.build(application, node)
  appserver = Drivers::Appserver::Factory.build(application, node)
  worker = Drivers::Worker::Factory.build(application, node)
  webserver = Drivers::Webserver::Factory.build(application, node)

  fire_hook(:before_undeploy, context: self, items: databases + [scm, framework, appserver, worker, webserver])

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

  fire_hook(:after_undeploy, context: self, items: databases + [scm, framework, appserver, worker, webserver])
end
