# frozen_string_literal: true

require 'spec_helper'

describe Drivers::Framework::Factory do
  it 'raises error when unknown adapter is present' do
    expect do
      described_class.build(
        dummy_context('deploy' => { aws_opsworks_app['shortname'] => { 'framework' => { 'adapter' => 'django' } } }),
        aws_opsworks_app
      )
    end.to raise_error StandardError, 'There is no supported Framework driver for given configuration.'
  end

  it 'returns a Rails class' do
    framework = described_class.build(dummy_context(node), aws_opsworks_app)
    expect(framework).to be_instance_of(Drivers::Framework::Rails)
  end
end
