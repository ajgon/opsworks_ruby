# frozen_string_literal: true

require 'spec_helper'

class TestLogrotateDriver < Drivers::Base
  include Drivers::Dsl::Logrotate
  allowed_engines :test
  adapter :test

  def app_engine
    'test'
  end
end

describe TestLogrotateDriver do
  let(:app) { aws_opsworks_app }
  let(:driver) { described_class.new(dummy_context(node), app) }

  it 'receives and exposes app and node' do
    expect(driver.app).to eq app
    expect(driver.send(:node)).to eq node
    expect(driver.options).to eq({})
  end

  describe '#logrotate_name' do
    subject(:name) { driver.logrotate_name }

    it 'defaults to something based on the app name and what-not' do
      expect(name).to eq('dummy_project-test-staging')
    end

    context 'when set via app global attributes' do
      let(:override_context) do
        dummy_context('deploy' => { app['shortname'] => { 'global' => { 'logrotate_name' => 'some-other-name' } } })
      end

      let(:driver) do
        described_class.new(override_context, aws_opsworks_app)
      end

      it 'uses the overridden name' do
        expect(name).to eq('some-other-name')
      end
    end
  end

  describe '#logrotate_log_paths' do
    subject(:paths) { driver.logrotate_log_paths }

    it 'should be empty by default' do
      expect(paths).to be_empty
    end

    let(:override_context) do
      dummy_context(
        'deploy' => {
          app['shortname'] => {
            'global' => {
              'logrotate_log_paths' => %w[
                /this/is/some/path/foo.log
                /this/is/some/other/path/bar.log
                /and/this/is/another/path/baz.log
              ]
            }
          }
        }
      )
    end

    context 'when set via app global attributes' do
      let(:driver) do
        described_class.new(override_context, aws_opsworks_app)
      end

      it 'uses the values in the app global attibutes' do
        expect(paths).to eq(%w[
                              /this/is/some/path/foo.log
                              /this/is/some/other/path/bar.log
                              /and/this/is/another/path/baz.log
                            ])
      end
    end

    context 'when set via DSL calls' do
      context 'when set as procs' do
        let(:proc1) do
          ->(context) { File.join('/foo', context.app['shortname'], 'log_dir', 'bar.log') }
        end
        let(:proc2) do
          ->(context) { File.join('/baz', context.app['shortname'], 'log_dir', 'quux.log') }
        end
        before do
          described_class.log_paths proc1, proc2
        end

        it 'returns the results of the proc calls' do
          expect(paths).to eq(%w[
                                /foo/dummy_project/log_dir/bar.log
                                /baz/dummy_project/log_dir/quux.log
                              ])
        end

        context 'but overridden by app global attributes' do
          let(:driver) do
            described_class.new(override_context, aws_opsworks_app)
          end

          it 'uses the values in the app global attibutes' do
            expect(paths).to eq(%w[
                                  /this/is/some/path/foo.log
                                  /this/is/some/other/path/bar.log
                                  /and/this/is/another/path/baz.log
                                ])
          end
        end
      end
    end
  end

  describe '#configure_logrotate' do
    subject(:configure) { driver.configure_logrotate }

    it 'calls the logrotate_app resource with default settings' do
    end
  end
end
