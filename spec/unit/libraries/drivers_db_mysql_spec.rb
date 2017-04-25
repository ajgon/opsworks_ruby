# frozen_string_literal: true

require 'spec_helper'
require 'unit/examples/db_validate_adapter_and_engine'
require 'unit/examples/db_parameters_and_connection'

describe Drivers::Db::Mysql do
  include_examples 'db validate adapter and engine', 'mysql'
  include_examples 'db parameters and connection', 'mysql', adapter: 'mysql2'
end
