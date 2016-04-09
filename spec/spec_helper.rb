# frozen_string_literal: true
require 'chefspec'
require 'chefspec/berkshelf'

# Require all libraries
Dir['libraries/*.rb'].each { |f| require File.expand_path(f) }

# Require all fixtures
Dir[File.expand_path('../fixtures/*.rb', __FILE__)].each { |f| require f }

at_exit { ChefSpec::Coverage.report! }
