# frozen_string_literal: true
# rubocop:disable Metrics/MethodLength
def node(override = {})
  item = {
    lsb: {
      codename: 'trusty'
    },
    nginx: {
      version: '1.4.6'
    },
    deploy: {
      dummy_project: {
        database: {
          adapter: 'postgresql',
          username: 'dbuser',
          password: '03c1bc98cdd5eb2f9c75',
          host: 'dummy-project.c298jfowejf.us-west-2.rds.amazon.com',
          database: 'dummydb',
          reaping_frequency: 10
        },
        scm: {
          adapter: 'git',
          user: 'dummy',
          password: '3aa161d358a167204502',
          revision: 'master',
          ssh_key: '--- SSH KEY ---',
          repository: 'git@git.example.com:repo/project.git',
          enable_submodules: false,
          ssh_wrapper: 'ssh-wrap',
          submodules: false,
          wrong_param: 'bad'
        },
        appserver: {
          adapter: 'unicorn',
          delay: 3
        },
        webserver: {
          adapter: 'nginx',
          client_max_body_size: '125m',
          dhparams: '--- DH PARAMS ---'
        },
        framework: {
          adapter: 'rails',
          migrate: false
        }
      }
    },
    defaults: {
      appserver: {
        adapter: 'unicorn',
        worker_processes: 8
      },
      webserver: {
        adapter: 'nginx',
        keepalive_timeout: '15'
      },
      framework: {
        adapter: 'rails',
        migration_command: 'rake db:migrate'
      }
    }
  }.merge(override)

  JSON.parse(item.to_json)
end
# rubocop:enable Metrics/MethodLength
