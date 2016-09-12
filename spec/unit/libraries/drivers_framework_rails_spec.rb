# frozen_string_literal: true
require 'spec_helper'

describe Drivers::Framework::Rails do
  it 'receives and exposes app and node' do
    driver = described_class.new(aws_opsworks_app, node)

    expect(driver.app).to eq aws_opsworks_app
    expect(driver.node).to eq node
    expect(driver.options).to eq({})
  end

  it 'returns proper out data' do
    expect(described_class.new(aws_opsworks_app, node).out).to eq(
      assets_precompile: true,
      assets_precompilation_command: 'bundle exec rake assets:precompile',
      envs_in_console: true,
      deploy_environment: { 'RAILS_ENV' => 'staging' },
      migration_command: 'rake db:migrate',
      migrate: false
    )
  end
end
