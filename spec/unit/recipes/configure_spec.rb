#
# Cookbook Name:: opsworks_ruby
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'opsworks_ruby::configure' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }
  context 'Database' do
    context 'Postgresql' do
      before do
        stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app])
        stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([aws_opsworks_rds_db_instance])
      end

      it 'installs required packages' do
        expect(chef_run).to install_package('libpq-dev')
      end
    end
  end
end
