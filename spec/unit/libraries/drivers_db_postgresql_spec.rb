# frozen_string_literal: true
require 'spec_helper'

describe Drivers::Db::Postgresql do
  it 'receives and exposes app, node and database bag' do
    driver = described_class.new(aws_opsworks_app, node, rds: aws_opsworks_rds_db_instance)

    expect(driver.app).to eq aws_opsworks_app
    expect(driver.node).to eq node
    expect(driver.options[:rds]).to eq aws_opsworks_rds_db_instance
  end

  it 'raises error when no rds is present' do
    expect do
      described_class.new(aws_opsworks_app, node, dummy_option: true)
    end.to raise_error ArgumentError, ':rds option is not set.'
  end

  context 'validate adapter and engine' do
    it 'adapter = missing, engine = missing' do
      expect do
        described_class.new(
          aws_opsworks_app, node(deploy: { dummy_project: {} }), rds: aws_opsworks_rds_db_instance(engine: nil)
        )
      end.to raise_error ArgumentError, "Missing :rds engine, expected #{described_class.allowed_engines.inspect}."
    end

    it 'adapter = missing, engine = wrong' do
      expect do
        described_class.new(
          aws_opsworks_app, node(deploy: { dummy_project: {} }), rds: aws_opsworks_rds_db_instance(engine: 'mysql')
        )
      end.to raise_error ArgumentError,
                         "Incorrect :rds engine, expected #{described_class.allowed_engines.inspect}, got 'mysql'."
    end

    it 'adapter = missing, engine = correct' do
      expect do
        described_class.new(
          aws_opsworks_app, node(deploy: { dummy_project: {} }), rds: aws_opsworks_rds_db_instance
        )
      end.not_to raise_error
    end

    it 'adapter = wrong, engine = missing' do
      expect do
        described_class.new(
          aws_opsworks_app,
          node(deploy: { dummy_project: { database: { adapter: 'mysql' } } }),
          rds: aws_opsworks_rds_db_instance(engine: nil)
        )
      end.to raise_error ArgumentError,
                         "Incorrect engine provided by adapter, expected #{described_class.allowed_engines.inspect}," \
                         ' got \'mysql\'.'
    end

    it 'adapter = wrong, engine = wrong' do
      expect do
        described_class.new(
          aws_opsworks_app,
          node(deploy: { dummy_project: { database: { adapter: 'mysql' } } }),
          rds: aws_opsworks_rds_db_instance(engine: 'mysql')
        )
      end.to raise_error ArgumentError,
                         "Incorrect :rds engine, expected #{described_class.allowed_engines.inspect}, got 'mysql'."
    end

    it 'adapter = wrong, engine = correct' do
      expect do
        described_class.new(
          aws_opsworks_app,
          node(deploy: { dummy_project: { database: { adapter: 'mysql' } } }),
          rds: aws_opsworks_rds_db_instance
        )
      end.not_to raise_error
    end

    it 'adapter = correct, engine = missing' do
      expect do
        described_class.new(
          aws_opsworks_app,
          node(deploy: { dummy_project: { database: { adapter: 'postgresql' } } }),
          rds: aws_opsworks_rds_db_instance
        )
      end.not_to raise_error
    end

    it 'adapter = correct, engine = wrong' do
      expect do
        described_class.new(
          aws_opsworks_app,
          node(deploy: { dummy_project: { database: { adapter: 'postgresql' } } }),
          rds: aws_opsworks_rds_db_instance(engine: 'mysql')
        )
      end.to raise_error ArgumentError,
                         "Incorrect :rds engine, expected #{described_class.allowed_engines.inspect}, got 'mysql'."
    end

    it 'adapter = correct, engine = correct' do
      expect do
        described_class.new(
          aws_opsworks_app,
          node(deploy: { dummy_project: { database: { adapter: 'postgresql' } } }),
          rds: aws_opsworks_rds_db_instance
        )
      end.not_to raise_error
    end
  end

  context 'connection data' do
    after(:each) do
      expect(@item.out).to eq(
        encoding: 'utf8',
        reconnect: true,
        adapter: 'postgresql',
        username: 'dbuser',
        password: '03c1bc98cdd5eb2f9c75',
        host: 'dummy-project.c298jfowejf.us-west-2.rds.amazon.com',
        database: 'dummydb',
        reaping_frequency: 10
      )
    end

    it 'taken from engine' do
      @item = described_class.new(aws_opsworks_app, node, rds: aws_opsworks_rds_db_instance)
    end

    it 'taken from adapter' do
      @item = described_class.new(aws_opsworks_app, node, rds: aws_opsworks_rds_db_instance(engine: nil))
    end
  end
end
