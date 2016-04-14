# frozen_string_literal: true
require 'spec_helper'

describe Drivers::Appserver::Factory do
  it 'raises error when unknown adapter is present' do
    expect do
      described_class.build(
        aws_opsworks_app,
        'deploy' => { aws_opsworks_app['shortname'] => { 'appserver' => { 'adapter' => 'tornado' } } }
      )
    end.to raise_error StandardError, 'There is no supported Appserver driver for given configuration.'
  end

  it 'returns a Unicorn class' do
    appserver = described_class.build(aws_opsworks_app, node)
    expect(appserver).to be_instance_of(Drivers::Appserver::Unicorn)
  end
end
