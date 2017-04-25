# frozen_string_literal: true

require 'bundler/setup'

desc 'Run Test Kitchen integration tests'
namespace :integration do
  desc 'Run integration tests with kitchen-vagrant'
  task :vagrant do
    require 'kitchen'
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each { |instance| instance.test(:always) }
  end

  desc 'Run integration tests with kitchen-docker'
  task :docker, [:instance] do |_t, args|
    args.with_defaults(instance: 'default-ubuntu-1404')
    require 'kitchen'
    Kitchen.logger = Kitchen.default_file_logger
    loader = Kitchen::Loader::YAML.new(local_config: '.kitchen.docker.yml')
    instances = Kitchen::Config.new(loader: loader).instances
    # Travis CI Docker service does not support destroy:
    instances.get(args.instance).verify
  end
end

task default: %w[integration:vagrant]
