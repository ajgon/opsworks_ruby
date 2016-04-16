# frozen_string_literal: true
require 'spec_helper'

describe Drivers::Webserver::Factory do
  it 'raises error when unknown adapter is present' do
    expect do
      described_class.build(
        aws_opsworks_app,
        'deploy' => { aws_opsworks_app['shortname'] => { 'webserver' => { 'adapter' => 'haproxy' } } }
      )
    end.to raise_error StandardError, 'There is no supported Webserver driver for given configuration.'
  end

  it 'returns a Nginx class' do
    webserver = described_class.build(aws_opsworks_app, node)
    expect(webserver).to be_instance_of(Drivers::Webserver::Nginx)
  end
end
