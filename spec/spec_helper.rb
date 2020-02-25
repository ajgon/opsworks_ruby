# frozen_string_literal: true

require 'chefspec'
require 'chefspec/berkshelf'
require 'pathname'

def dummy_context(node)
  OpenStruct.new(node: node)
end

def fixture_path(*path)
  Pathname.new(File.expand_path('fixtures', __dir__)).join(*path)
end

# Stolen from https://github.com/rails/rails/pull/30275 and put
# into a dedicated class to avoid collisions in any environment
# that has already monkey-patched Hash.deep_merge
module RubyOpsworksTests
  class DeepMergeableHash
    def initialize(hsh = {})
      @target = hsh
    end

    def deep_merge(other_hash, &block)
      deep_merge!(other_hash, &block)
    end

    def deep_merge!(other, &block)
      @target.dup.merge!(other) do |key, old_val, new_val|
        if old_val.is_a?(Hash) && new_val.is_a?(Hash)
          DeepMergeableHash.new(old_val).deep_merge(new_val, &block)
        elsif block_given?
          yield(key, old_val, new_val)
        else
          new_val
        end
      end
    end
  end
end

# Require all libraries
require File.expand_path('../libraries/all.rb', __dir__)

# Require all fixtures
Dir[File.expand_path('fixtures/*.rb', __dir__)].sort.each { |f| require f }

RSpec.configure do |config|
  config.log_level = :error
end

# coveralls
require 'coveralls'
Coveralls.wear!

at_exit { ChefSpec::Coverage.report! }
