# frozen_string_literal: true

def aws_opsworks_app(override = {})
  item = {
    app_id: '3aef37c1-7e2b-4255-bbf1-03e06f07701a',
    app_source: {
      password: '3aa161d358a167204502',
      revision: 'master',
      ssh_key: '--- SSH KEY ---',
      type: 'git',
      url: 'git@git.example.com:repo/project.git',
      user: 'dummy'
    },
    attributes: {
      auto_bundle_on_deploy: true,
      aws_flow_ruby_settings: {},
      document_root: 'dummy_project',
      rails_env: nil
    },
    data_sources: [
      { arn: 'arn:aws:rds:us-west-2:850906259207:db:dummy-project', type: 'RdsDbInstance', database_name: 'dummydb' }
    ],
    domains: ['dummy-project.example.com', 'dummy_project'],
    enable_ssl: true,
    environment: {
      'ENV_VAR1' => 'test',
      'ENV_VAR2' => 'some data'
    },
    name: 'Dummy app',
    shortname: 'dummy_project',
    ssl_configuration: {
      certificate: '--- SSL CERTIFICATE ---',
      private_key: '--- SSL PRIVATE KEY ---',
      chain: '--- SSL CERTIFICATE CHAIN ---'
    },
    type: 'other',
    deploy: true,
    id: 'dummy_project'
  }.merge(override)

  JSON.parse(item.to_json)
end
