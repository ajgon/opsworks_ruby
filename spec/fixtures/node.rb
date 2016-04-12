# frozen_string_literal: true
# rubocop:disable Metrics/MethodLength
def node(override = {})
  item = {
    lsb: {
      codename: 'trusty'
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
        }
      }
    }
  }.merge(override)

  JSON.parse(item.to_json)
end
# rubocop:enable Metrics/MethodLength
