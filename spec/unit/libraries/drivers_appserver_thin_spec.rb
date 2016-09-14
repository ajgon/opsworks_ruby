# frozen_string_literal: true
require 'spec_helper'

describe Drivers::Appserver::Thin do
  it 'receives and exposes app and node' do
    driver = described_class.new(aws_opsworks_app, node)

    expect(driver.app).to eq aws_opsworks_app
    expect(driver.node).to eq node
    expect(driver.options).to eq({})
  end

  it 'returns proper out data' do
    expect(described_class.new(aws_opsworks_app, node).out).to eq(
      max_connections: 4096,
      worker_processes: 8
    )
  end
end
