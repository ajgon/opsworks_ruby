# frozen_string_literal: true
require 'spec_helper'

describe Drivers::Framework::Factory do
  it 'raises error when unknown adapter is present' do
    expect do
      described_class.build(
        aws_opsworks_app,
        'deploy' => { aws_opsworks_app['shortname'] => { 'framework' => { 'adapter' => 'django' } } }
      )
    end.to raise_error StandardError, 'There is no supported Framework driver for given configuration.'
  end

  it 'returns a Rails class' do
    framework = described_class.build(aws_opsworks_app, node)
    expect(framework).to be_instance_of(Drivers::Framework::Rails)
  end
end
