# frozen_string_literal: true

require 'spec_helper'

describe Drivers::Framework::Hanami do
  it 'receives and exposes app and node' do
    driver = described_class.new(dummy_context(node), aws_opsworks_app)

    expect(driver.app).to eq aws_opsworks_app
    expect(driver.send(:node)).to eq node
    expect(driver.options).to eq({})
  end

  it 'returns proper out data' do
    expect(described_class.new(dummy_context(node), aws_opsworks_app).out).to eq(
      assets_precompile: true,
      assets_precompilation_command: '/usr/local/bin/bundle exec hanami assets precompile',
      deploy_environment: {
        'HANAMI_ENV' => 'staging',
        'DATABASE_URL' => 'sqlite:///srv/www/dummy_project/shared/db/dummy_project_staging.sqlite'
      },
      migration_command: '/usr/local/bin/bundle exec hanami db migrate',
      migrate: false
    )
  end
end
