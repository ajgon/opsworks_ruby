# frozen_string_literal: true
RSpec.shared_examples 'db validate adapter and engine' do |rdbms|
  context "#{rdbms}: validate adapter and engine" do
    it 'adapter = missing, engine = missing' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: {} })),
          aws_opsworks_app,
          rds: aws_opsworks_rds_db_instance(engine: nil)
        ).out
      end.to raise_error ArgumentError,
                         "Missing :app or :node engine, expected #{described_class.allowed_engines.inspect}."
    end

    it 'adapter = missing, engine = wrong' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: {} })),
          aws_opsworks_app,
          rds: aws_opsworks_rds_db_instance(engine: 'wrong')
        ).out
      end.to raise_error ArgumentError,
                         "Incorrect :app engine, expected #{described_class.allowed_engines.inspect}, got 'wrong'."
    end

    it 'adapter = missing, engine = correct' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: {} })),
          aws_opsworks_app,
          rds: aws_opsworks_rds_db_instance(engine: rdbms)
        ).out
      end.not_to raise_error
    end

    it 'adapter = wrong, engine = missing' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: { database: { adapter: 'wrong' } } })),
          aws_opsworks_app,
          rds: aws_opsworks_rds_db_instance(engine: nil)
        ).out
      end.to raise_error ArgumentError,
                         "Incorrect :node engine, expected #{described_class.allowed_engines.inspect}, got 'wrong'."
    end

    it 'adapter = wrong, engine = wrong' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: { database: { adapter: 'wrong' } } })),
          aws_opsworks_app,
          rds: aws_opsworks_rds_db_instance(engine: 'wrong')
        ).out
      end.to raise_error ArgumentError,
                         "Incorrect :app engine, expected #{described_class.allowed_engines.inspect}, got 'wrong'."
    end

    it 'adapter = wrong, engine = correct' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: { database: { adapter: 'wrong' } } })),
          aws_opsworks_app,
          rds: aws_opsworks_rds_db_instance(engine: rdbms)
        ).out
      end.not_to raise_error
    end

    it 'adapter = correct, engine = missing' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: { database: { adapter: rdbms } } })),
          aws_opsworks_app,
          rds: aws_opsworks_rds_db_instance(engine: nil)
        ).out
      end.not_to raise_error
    end

    it 'adapter = correct, engine = wrong' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: { database: { adapter: rdbms } } })),
          aws_opsworks_app,
          rds: aws_opsworks_rds_db_instance(engine: 'wrong')
        ).out
      end.to raise_error ArgumentError,
                         "Incorrect :app engine, expected #{described_class.allowed_engines.inspect}, got 'wrong'."
    end

    it 'adapter = correct, engine = correct' do
      expect do
        described_class.new(
          dummy_context(node(deploy: { dummy_project: { database: { adapter: rdbms } } })),
          aws_opsworks_app,
          rds: aws_opsworks_rds_db_instance(engine: rdbms)
        ).out
      end.not_to raise_error
    end
  end
end
