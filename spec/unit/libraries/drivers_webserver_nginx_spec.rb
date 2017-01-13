# frozen_string_literal: true
require 'spec_helper'

describe Drivers::Webserver::Nginx do
  it 'receives and exposes app and node' do
    driver = described_class.new(dummy_context(node), aws_opsworks_app)

    expect(driver.app).to eq aws_opsworks_app
    expect(driver.send(:node)).to eq node
    expect(driver.options).to eq({})
  end

  it 'returns proper out data' do
    expect(described_class.new(dummy_context(node), aws_opsworks_app).out).to eq(
      client_max_body_size: '125m',
      client_body_timeout: '30',
      dhparams: '--- DH PARAMS ---',
      keepalive_timeout: '65',
      log_level: 'debug',
      extra_config: 'extra_config {}',
      extra_config_ssl: 'extra_config_ssl {}'
    )
  end

  it 'copies extra_config to extra_config_ssl if extra_config_ssl is set to true' do
    expect(
      described_class.new(
        dummy_context(node(defaults: { webserver: { extra_config_ssl: true } })),
        aws_opsworks_app
      ).out
    ).to eq(
      client_max_body_size: '125m',
      client_body_timeout: '30',
      dhparams: '--- DH PARAMS ---',
      log_level: 'debug',
      extra_config: 'extra_config {}',
      extra_config_ssl: 'extra_config {}'
    )
  end
end
