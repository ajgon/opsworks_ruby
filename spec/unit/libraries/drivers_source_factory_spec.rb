# frozen_string_literal: true

require 'spec_helper'

describe Drivers::Source::Factory do
  it 'raises error when unknown engine is present' do
    node_data = node
    node_data['deploy']['dummy_project']['source'] = {}

    expect do
      described_class.build(dummy_context(node_data), aws_opsworks_app(app_source: nil))
    end.to raise_error StandardError, 'There is no supported Source driver for given configuration.'
  end

  it 'returns a Git class' do
    source = described_class.build(dummy_context(node), aws_opsworks_app)
    expect(source).to be_instance_of(Drivers::Source::Git)
  end

  it 'returns a S3 class from app source' do
    node_data = node
    node_data['deploy']['dummy_project']['source'] = {}

    source = described_class.build(
      dummy_context(node_data), aws_opsworks_app(app_source: { type: 's3', url: 'http://example.com' })
    )
    expect(source).to be_instance_of(Drivers::Source::S3)
  end

  it 'returns a S3 class from node source' do
    node_data = node
    node_data['deploy']['dummy_project']['source'] = { 'adapter' => 's3', 'url' => 'http://example.com' }

    source = described_class.build(dummy_context(node_data), aws_opsworks_app(app_source: nil))
    expect(source).to be_instance_of(Drivers::Source::S3)
  end

  it 'returns a Http class from app source' do
    node_data = node
    node_data['deploy']['dummy_project']['source'] = {}

    source = described_class.build(
      dummy_context(node_data), aws_opsworks_app(app_source: { type: 'archive', url: 'http://example.com' })
    )
    expect(source).to be_instance_of(Drivers::Source::Http)
  end

  it 'returns a Http class from node source' do
    node_data = node
    node_data['deploy']['dummy_project']['source'] = { 'adapter' => 'http', 'url' => 'http://example.com' }

    source = described_class.build(dummy_context(node_data), aws_opsworks_app(app_source: nil))
    expect(source).to be_instance_of(Drivers::Source::Http)
  end
end
