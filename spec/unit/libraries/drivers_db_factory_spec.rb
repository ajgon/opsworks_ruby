# frozen_string_literal: true

require 'spec_helper'

describe Drivers::Db::Factory do
  it 'raises error when unknown engine is present' do
    expect do
      described_class.build(dummy_context(node), aws_opsworks_app, rds: { 'engine' => 'unknown' })
    end.to raise_error StandardError, 'There is no supported Db driver for given configuration.'
  end

  it 'returns a Postgresql class' do
    db = described_class.build(dummy_context(node), aws_opsworks_app, rds: aws_opsworks_rds_db_instance)
    expect(db).to be_instance_of(Drivers::Db::Postgresql)
  end
end
