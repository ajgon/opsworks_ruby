# frozen_string_literal: true

DEFAULT_NODE = {
  lsb: {
    codename: 'trusty'
  },
  nginx: {
    version: '1.4.6',
    client_body_timeout: '30'
  },
  deploy: {
    dummy_project: {
      global: {
        environment: 'staging',
        create_dirs_before_symlink: %(../shared/test),
        purge_before_symlink: %w[public/test],
        do_not_purge_before_symlink: %w[tmp/pids],
        symlinks: { 'test' => 'public/test' }
      },
      # database: {
      #   adapter: 'postgresql',
      #   username: 'dbuser',
      #   password: '03c1bc98cdd5eb2f9c75',
      #   host: 'dummy-project.c298jfowejf.us-west-2.rds.amazon.com',
      #   database: 'dummydb',
      #   reaping_frequency: 10
      # },
      source: {
        adapter: 'git',
        user: 'dummy',
        password: '3aa161d358a167204502',
        revision: 'master',
        ssh_key: '--- SSH KEY ---',
        url: 'git@git.example.com:repo/project.git',
        enable_submodules: false,
        ssh_wrapper: 'ssh-wrap',
        submodules: false,
        wrong_param: 'bad'
      },
      appserver: {
        adapter: 'unicorn',
        delay: 3,
        thread_min: 0,
        thread_max: 16,
        max_connections: 4096
      },
      webserver: {
        adapter: 'nginx',
        client_max_body_size: '125m',
        limit_request_body: '131072000',
        dhparams: '--- DH PARAMS ---',
        extra_config: 'extra_config {}',
        log_level: 'debug'
      },
      framework: {
        adapter: 'rails',
        migrate: false,
        envs_in_console: true
      },
      worker: {
        adapter: 'sidekiq',
        require: 'lorem_ipsum.rb',
        require_rails: true,
        queues: 'test_queue'
      }
    }
  },
  defaults: {
    global: {
      symlinks: {
        system: 'public/system',
        assets: 'public/assets',
        cache: 'tmp/cache',
        pids: 'tmp/pids',
        log: 'log'
      },
      create_dirs_before_symlink: %w[tmp public config ../../shared/cache ../../shared/assets],
      purge_before_symlink: %w[log tmp/cache tmp/pids public/system public/assets]
    },
    source: {
      remove_scm_files: true
    },
    appserver: {
      adapter: 'unicorn',
      worker_processes: 8,
      after_deploy: 'stop-start'
    },
    webserver: {
      adapter: 'nginx',
      keepalive_timeout: '65',
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
}.freeze

def node(override = {}, deep_merge = false)
  item =
    if deep_merge
      RubyOpsworksTests::DeepMergeableHash.new(DEFAULT_NODE).deep_merge(override)
    else
      DEFAULT_NODE.merge(override)
    end
  JSON.parse(item.to_json)
end
