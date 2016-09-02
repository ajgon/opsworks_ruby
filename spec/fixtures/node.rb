# frozen_string_literal: true
# rubocop:disable Metrics/MethodLength
def node(override = {})
  item = {
    lsb: {
      codename: 'trusty'
    },
    nginx: {
      version: '1.4.6',
      client_body_timeout: '30'
    },
    deploy: {
      dummy_project: {
        environment: 'staging',
        # database: {
        #   adapter: 'postgresql',
        #   username: 'dbuser',
        #   password: '03c1bc98cdd5eb2f9c75',
        #   host: 'dummy-project.c298jfowejf.us-west-2.rds.amazon.com',
        #   database: 'dummydb',
        #   reaping_frequency: 10
        # },
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
          delay: 3,
          thread_min: 0,
          thread_max: 16
        },
        webserver: {
          adapter: 'nginx',
          client_max_body_size: '125m',
          dhparams: '--- DH PARAMS ---',
          extra_config: 'extra_config {}'
        },
        framework: {
          adapter: 'rails',
          migrate: false
        },
        worker: {
          adapter: 'sidekiq',
          require: 'lorem_ipsum.rb'
        },
        create_dirs_before_symlink: %(../shared/test),
        purge_before_symlink: %w(public/test),
        symlinks: { 'test' => 'public/test' }
      }
    },
    defaults: {
      deploy: {
        symlinks: {
          system: 'public/system',
          assets: 'public/assets',
          cache: 'tmp/cache',
          pids: 'tmp/pids',
          log: 'log'
        },
        create_dirs_before_symlink: %w(tmp public config ../../shared/cache ../../shared/assets),
        purge_before_symlink: %w(log tmp/cache tmp/pids public/system public/assets)
      },
      scm: {
        remove_scm_files: true
      },
      appserver: {
        adapter: 'unicorn',
        worker_processes: 8
      },
      webserver: {
        adapter: 'nginx',
        keepalive_timeout: '15',
        extra_config_ssl: 'extra_config_ssl {}'
      },
      framework: {
        adapter: 'rails',
        migration_command: 'rake db:migrate',
        assets_precompile: true,
        assets_precompilation_command: 'bundle exec rake assets:precompile'
      },
      worker: {
        adapter: 'null',
        process_count: 2,
        syslog: true,
        config: { 'concurency' => 5, 'verbose' => false, 'queues' => ['default'] }
      }
    }
  }.merge(override)

  JSON.parse(item.to_json)
end
# rubocop:enable Metrics/MethodLength
