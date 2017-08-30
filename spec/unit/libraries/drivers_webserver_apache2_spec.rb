# frozen_string_literal: true

require 'spec_helper'

describe Drivers::Webserver::Apache2 do
  let(:driver) { described_class.new(dummy_context(node), aws_opsworks_app) }

  it 'receives and exposes app and node' do
    expect(driver.app).to eq aws_opsworks_app
    expect(driver.send(:node)).to eq node
    expect(driver.options).to eq({})
  end

  it 'has the correct driver_type' do
    expect(driver.driver_type).to eq('webserver')
  end

  it 'returns proper out data' do
    expect(driver.out).to eq(
      dhparams: '--- DH PARAMS ---',
      keepalive_timeout: '65',
      limit_request_body: '131072000',
      extra_config: 'extra_config {}',
      extra_config_ssl: 'extra_config_ssl {}',
      log_dir: '/var/log/httpd',
      log_level: 'debug'
    )
  end

  it 'copies extra_config to extra_config_ssl if extra_config_ssl is set to true' do
    expect(
      described_class.new(
        dummy_context(node(defaults: { webserver: { extra_config_ssl: true } })),
        aws_opsworks_app
      ).out
    ).to eq(
      dhparams: '--- DH PARAMS ---',
      limit_request_body: '131072000',
      extra_config: 'extra_config {}',
      extra_config_ssl: 'extra_config {}',
      log_dir: '/var/log/httpd',
      log_level: 'debug'
    )
  end
end
