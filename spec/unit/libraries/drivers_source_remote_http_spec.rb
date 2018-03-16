# frozen_string_literal: true

require 'spec_helper'

describe Drivers::Source::Remote::Http do
  let(:http_aws_opsworks_app) do
    aws_opsworks_app(
      app_source: {
        password: 'password',
        type: 'archive',
        url: 'https://example.com/path/file.tar.gz',
        user: 'user'
      }
    )
  end
  let(:driver) { described_class.new(dummy_context(node), http_aws_opsworks_app) }

  it 'receives and exposes app and node' do
    expect(driver.app).to eq http_aws_opsworks_app
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
        described_class.new(dummy_context(node(deploy: { dummy_project: {} })), http_aws_opsworks_app).out
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
          dummy_context(node(deploy: { dummy_project: { source: { adapter: 'svn' } } })), http_aws_opsworks_app
        ).out
      end.not_to raise_error
    end

    it 'adapter = correct, engine = missing' do
      expect do
        described_class.new(
          dummy_context(
            node(deploy: { dummy_project: { source: { adapter: 'http', url: 'http://example.com' } } })
          ),
          aws_opsworks_app(app_source: nil)
        ).out
      end.not_to raise_error
    end

    it 'adapter = correct, engine = wrong' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: { source: { adapter: 'http' } } })),
          aws_opsworks_app(app_source: { type: 'svn' })
        ).out
      end.to raise_error ArgumentError,
                         "Incorrect :app engine, expected #{described_class.allowed_engines.inspect}, got 'svn'."
    end

    it 'adapter = correct, engine = correct' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: { source: { adapter: 'http' } } })), http_aws_opsworks_app
        ).out
      end.not_to raise_error
    end
  end

  context 'connection data' do
    after(:each) do
      expect(@item.out).to eq(
        password: 'password',
        url: 'https://example.com/path/file.tar.gz',
        user: 'user'
      )
    end

    it 'taken from engine' do
      @item = described_class.new(dummy_context(node), http_aws_opsworks_app)
    end

    it 'taken from adapter' do
      node_data = node
      node_data['deploy']['dummy_project']['source'] = {
        'adapter' => 'http',
        'password' => 'password',
        'url' => 'https://example.com/path/file.tar.gz',
        'user' => 'user'
      }
      @item = described_class.new(dummy_context(node_data), aws_opsworks_app(app_source: nil))
    end
  end
end
