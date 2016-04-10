# frozen_string_literal: true
require 'spec_helper'

describe Drivers::Scm::Factory do
  it 'raises error when unknown engine is present' do
    expect do
      described_class.build(aws_opsworks_app(app_source: nil), node)
    end.to raise_error StandardError, 'There is no supported Scm driver for given configuration.'
  end

  it 'returns a Git class' do
    scm = described_class.build(aws_opsworks_app, node)
    expect(scm).to be_instance_of(Drivers::Scm::Git)
  end
end
