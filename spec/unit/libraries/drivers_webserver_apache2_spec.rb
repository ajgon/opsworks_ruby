# frozen_string_literal: true
require 'spec_helper'

describe Drivers::Webserver::Apache2 do
  it 'receives and exposes app and node' do
    driver = described_class.new(aws_opsworks_app, node)

    expect(driver.app).to eq aws_opsworks_app
    expect(driver.node).to eq node
    expect(driver.options).to eq({})
  end

  it 'returns proper out data' do
    expect(described_class.new(aws_opsworks_app, node).out).to eq(
      dhparams: '--- DH PARAMS ---',
      keepalive_timeout: '65',
      limit_request_body: '131072000',
      extra_config: 'extra_config {}',
      extra_config_ssl: 'extra_config_ssl {}',
      log_dir: '/var/log/httpd'
    )
  end

  it 'copies extra_config to extra_config_ssl if extra_config_ssl is set to true' do
    expect(described_class.new(aws_opsworks_app, node(defaults: { webserver: { extra_config_ssl: true } })).out).to eq(
      dhparams: '--- DH PARAMS ---',
      limit_request_body: '131072000',
      extra_config: 'extra_config {}',
      extra_config_ssl: 'extra_config {}',
      log_dir: '/var/log/httpd'
    )
  end
end
