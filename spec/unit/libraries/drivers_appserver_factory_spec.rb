# frozen_string_literal: true

require 'spec_helper'

describe Drivers::Appserver::Factory do
  it 'raises error when unknown adapter is present' do
    expect do
      described_class.build(
        dummy_context('deploy' => { aws_opsworks_app['shortname'] => { 'appserver' => { 'adapter' => 'tornado' } } }),
        aws_opsworks_app
      )
    end.to raise_error StandardError, 'There is no supported Appserver driver for given configuration.'
  end

  it 'returns a Unicorn class' do
    appserver = described_class.build(dummy_context(node), aws_opsworks_app)
    expect(appserver).to be_instance_of(Drivers::Appserver::Unicorn)
  end

  context 'when adapter is null' do
    it 'returns a Null class' do
      appserver = described_class.build(
        dummy_context(node(deploy: { dummy_project: { appserver: { adapter: 'null' } } })),
        aws_opsworks_app
      )
      expect(appserver).to be_instance_of(Drivers::Appserver::Null)
    end
  end
end
