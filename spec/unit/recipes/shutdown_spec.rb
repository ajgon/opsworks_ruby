# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Spec:: shutdown
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'opsworks_ruby::shutdown' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |solo_node|
      solo_node.set['deploy'] = node['deploy']
    end.converge(described_recipe)
  end
  before do
    stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app])
    stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([aws_opsworks_rds_db_instance])
  end

  it 'works' do
    expect do
      chef_run
    end.not_to raise_error
  end
end
