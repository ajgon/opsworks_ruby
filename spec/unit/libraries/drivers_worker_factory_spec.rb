# frozen_string_literal: true
require 'spec_helper'

describe Drivers::Worker::Factory do
  it 'raises error when unknown adapter is present' do
    expect do
      described_class.build(
        aws_opsworks_app,
        'deploy' => { aws_opsworks_app['shortname'] => { 'worker' => { 'adapter' => 'rq' } } }
      )
    end.to raise_error StandardError, 'There is no supported Worker driver for given configuration.'
  end

  it 'returns a Sidekiq class' do
    worker = described_class.build(aws_opsworks_app, node)
    expect(worker).to be_instance_of(Drivers::Worker::Sidekiq)
  end
end
