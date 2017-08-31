# frozen_string_literal: true

require 'spec_helper'

module Drivers
  class TestDriver < Drivers::Base
    include Drivers::Dsl::Logrotate
    allowed_engines :test_engine
    adapter :test_adapter

    def app_engine
      'test_engine'
    end
  end
end

describe Drivers::TestDriver do
  let(:app) { aws_opsworks_app }
  let(:driver) { described_class.new(dummy_context(node), app) }

  it 'receives and exposes app and node' do
    expect(driver.app).to eq app
    expect(driver.send(:node)).to eq node
    expect(driver.options).to eq({})
  end

  describe '#logrotate_name' do
    subject(:name) { driver.logrotate_name }
    let(:default_name) { 'dummy_project-test_adapter-staging' }

    it 'defaults to something based on the app name and what-not' do
      expect(name).to eq(default_name)
    end

    context 'with attempts to override' do
      let(:driver) do
        described_class.new(dummy_context(node(override_attrs, true)), aws_opsworks_app)
      end

      context 'via app+driver_type attributes' do
        let(:override_attrs) do
          {
            deploy: {
              app['shortname'].to_sym => {
                testdriver: {
                  logrotate_name: 'some-other-name'
                }
              }
            }
          }
        end

        it 'uses the overridden name' do
          expect(name).to eq('some-other-name')
        end
      end

      context 'via app global attributes' do
        let(:override_attrs) do
          {
            deploy: {
              app['shortname'].to_sym => {
                global: {
                  logrotate_name: 'some-other-name'
                }
              }
            }
          }
        end

        it 'does not use the overridden name' do
          expect(name).to eq(default_name)
        end
      end

      context 'via default driver_type attributes' do
        let(:override_attrs) do
          {
            defaults: {
              testdriver: {
                logrotate_name: 'some-other-name'
              }
            }
          }
        end

        it 'does not use the overridden name' do
          expect(name).to eq(default_name)
        end
      end

      context 'via global attributes' do
        let(:override_attrs) do
          {
            defaults: {
              global: {
                logrotate_name: 'some-other-name'
              }
            }
          }
        end

        it 'does not use the overridden name' do
          expect(name).to eq(default_name)
        end
      end
    end
  end

  describe '#logrotate_log_paths' do
    subject(:paths) { driver.logrotate_log_paths }

    it 'should be empty by default' do
      expect(paths).to be_empty
    end

    let(:override_log_paths) do
      %w[
        /this/is/some/path/foo.log
        /this/is/some/other/path/bar.log
        /and/this/is/another/path/baz.log
      ]
    end

    context 'with attempts to override' do
      let(:driver) do
        described_class.new(dummy_context(node(override_attrs, true)), aws_opsworks_app)
      end

      context 'via app+driver_type attributes' do
        let(:override_attrs) do
          {
            deploy: {
              app['shortname'].to_sym => {
                testdriver: {
                  logrotate_log_paths: override_log_paths
                }
              }
            }
          }
        end

        it 'uses the overridden log_paths' do
          expect(paths).to eq(override_log_paths)
        end
      end

      context 'via app global attributes' do
        let(:override_attrs) do
          {
            deploy: {
              app['shortname'].to_sym => {
                global: {
                  logrotate_log_paths: override_log_paths
                }
              }
            }
          }
        end

        it 'does not use the overridden log_paths' do
          expect(paths).to be_empty
        end
      end

      context 'via default driver_type attributes' do
        let(:override_attrs) do
          {
            defaults: {
              testdriver: {
                logrotate_log_paths: override_log_paths
              }
            }
          }
        end

        it 'does not use the overridden log paths' do
          expect(paths).to be_empty
        end
      end

      context 'via global attributes' do
        let(:override_attrs) do
          {
            defaults: {
              global: {
                logrotate_log_paths: override_log_paths
              }
            }
          }
        end

        it 'does not use the overridden log paths' do
          expect(paths).to be_empty
        end
      end
    end

    context 'when set via DSL calls' do
      context 'when set as procs' do
        let(:proc_logs) do
          %w[
            /foo/dummy_project/log_dir/bar.log
            /baz/dummy_project/log_dir/quux.log
          ]
        end
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
          expect(paths).to eq(proc_logs)
        end

        context 'with attempts to override' do
          let(:driver) do
            described_class.new(dummy_context(node(override_attrs, true)), aws_opsworks_app)
          end

          context 'via app+driver_type attributes' do
            let(:override_attrs) do
              {
                deploy: {
                  app['shortname'].to_sym => {
                    testdriver: {
                      logrotate_log_paths: override_log_paths
                    }
                  }
                }
              }
            end

            it 'uses the overridden log_paths' do
              expect(paths).to eq(override_log_paths)
            end
          end

          context 'via app global attributes' do
            let(:override_attrs) do
              {
                deploy: {
                  app['shortname'].to_sym => {
                    global: {
                      logrotate_log_paths: override_log_paths
                    }
                  }
                }
              }
            end

            it 'does not use the overridden log_paths and calls the provided procs instead' do
              expect(paths).to eq(proc_logs)
            end
          end

          context 'via default driver_type attributes' do
            let(:override_attrs) do
              {
                defaults: {
                  testdriver: {
                    logrotate_log_paths: override_log_paths
                  }
                }
              }
            end

            it 'does not use the overridden log paths and calls the provided procs instead' do
              expect(paths).to eq(proc_logs)
            end
          end

          context 'via global attributes' do
            let(:override_attrs) do
              {
                defaults: {
                  global: {
                    logrotate_log_paths: override_log_paths
                  }
                }
              }
            end

            it 'does not use the overridden log_paths and calls the provided_procs instead' do
              expect(paths).to eq(proc_logs)
            end
          end
        end
      end
    end
  end
end
