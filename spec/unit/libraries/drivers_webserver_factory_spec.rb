# frozen_string_literal: true
require 'spec_helper'

describe Drivers::Webserver::Factory do
  it 'raises error when unknown adapter is present' do
    expect do
      described_class.build(
        dummy_context('deploy' => { aws_opsworks_app['shortname'] => { 'webserver' => { 'adapter' => 'haproxy' } } }),
        aws_opsworks_app
      )
    end.to raise_error StandardError, 'There is no supported Webserver driver for given configuration.'
  end

  it 'returns a Nginx class' do
    webserver = described_class.build(dummy_context(node), aws_opsworks_app)
    expect(webserver).to be_instance_of(Drivers::Webserver::Nginx)
  end

  context 'when adapter is null' do
    it 'returns a Null class' do
      webserver = described_class.build(
        dummy_context(node(deploy: { dummy_project: { webserver: { adapter: 'null' } } })),
        aws_opsworks_app
      )
      expect(webserver).to be_instance_of(Drivers::Webserver::Null)
    end
  end
end
