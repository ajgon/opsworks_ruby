# frozen_string_literal: true
require 'chefspec'
require 'chefspec/berkshelf'

# Require all libraries
Dir['libraries/*.rb'].each { |f| require File.expand_path(f) }

# Require all fixtures
Dir[File.expand_path('../fixtures/*.rb', __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.log_level = :error
end

at_exit { ChefSpec::Coverage.report! }
