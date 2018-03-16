# frozen_string_literal: true

require 'spec_helper'

describe Drivers::Source::Remote::S3 do
  let(:s3_aws_opsworks_app) do
    aws_opsworks_app(
      app_source: {
        password: 'AWS_SECRET_ACCESS_KEY',
        type: 's3',
        url: 'https://s3.amazonaws.com/bucket/file.tar.gz',
        user: 'AWS_ACCESS_KEY_ID'
      }
    )
  end
  let(:driver) { described_class.new(dummy_context(node), s3_aws_opsworks_app) }

  it 'receives and exposes app and node' do
    expect(driver.app).to eq s3_aws_opsworks_app
    expect(driver.send(:node)).to eq node
    expect(driver.options).to eq({})
  end

  it 'has the correct driver_type' do
    expect(driver.driver_type).to eq('source')
  end

  context 'validate adapter and engine' do
    it 'adapter = missing, engine = missing' do
      expect do
        described_class.new(dummy_context(node(deploy: { dummy_project: {} })), aws_opsworks_app(app_source: nil)).out
      end.to raise_error ArgumentError,
                         "Missing :app or :node engine, expected #{described_class.allowed_engines.inspect}."
    end

    it 'adapter = missing, engine = wrong' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: {} })),
          aws_opsworks_app(app_source: { type: 'svn' })
        ).out
      end.to raise_error ArgumentError,
                         "Incorrect :app engine, expected #{described_class.allowed_engines.inspect}, got 'svn'."
    end

    it 'adapter = missing, engine = correct' do
      expect do
        described_class.new(dummy_context(node(deploy: { dummy_project: {} })), s3_aws_opsworks_app).out
      end.not_to raise_error
    end

    it 'adapter = wrong, engine = missing' do
      expect do
        described_class.new(
          dummy_context(
            node(deploy: { dummy_project: { source: { adapter: 'svn' } } })
          ),
          aws_opsworks_app(app_source: nil)
        ).out
      end.to raise_error ArgumentError,
                         "Incorrect :node engine, expected #{described_class.allowed_engines.inspect}, got 'svn'."
    end

    it 'adapter = wrong, engine = wrong' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: { source: { adapter: 'svn' } } })),
          aws_opsworks_app(app_source: { type: 'svn' })
        ).out
      end.to raise_error ArgumentError,
                         "Incorrect :app engine, expected #{described_class.allowed_engines.inspect}, got 'svn'."
    end

    it 'adapter = wrong, engine = correct' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: { source: { adapter: 'svn' } } })), s3_aws_opsworks_app
        ).out
      end.not_to raise_error
    end

    it 'adapter = correct, engine = missing' do
      expect do
        described_class.new(
          dummy_context(
            node(deploy: { dummy_project: { source: { adapter: 's3', url: 'http://example.com' } } })
          ),
          aws_opsworks_app(app_source: nil)
        ).out
      end.not_to raise_error
    end

    it 'adapter = correct, engine = wrong' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: { source: { adapter: 's3' } } })),
          aws_opsworks_app(app_source: { type: 'svn' })
        ).out
      end.to raise_error ArgumentError,
                         "Incorrect :app engine, expected #{described_class.allowed_engines.inspect}, got 'svn'."
    end

    it 'adapter = correct, engine = correct' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: { source: { adapter: 's3' } } })), s3_aws_opsworks_app
        ).out
      end.not_to raise_error
    end
  end

  context 'connection data' do
    after(:each) do
      expect(@item.out).to eq(
        password: 'AWS_SECRET_ACCESS_KEY',
        url: 'https://s3.amazonaws.com/bucket/file.tar.gz',
        user: 'AWS_ACCESS_KEY_ID'
      )
    end

    it 'taken from engine' do
      @item = described_class.new(dummy_context(node), s3_aws_opsworks_app)
    end

    it 'taken from adapter' do
      node_data = node
      node_data['deploy']['dummy_project']['source'] = {
        'adapter' => 's3',
        'password' => 'AWS_SECRET_ACCESS_KEY',
        'url' => 'https://s3.amazonaws.com/bucket/file.tar.gz',
        'user' => 'AWS_ACCESS_KEY_ID'
      }
      @item = described_class.new(dummy_context(node_data), aws_opsworks_app(app_source: nil))
    end
  end
end
