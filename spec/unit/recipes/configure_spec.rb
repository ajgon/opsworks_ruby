# frozen_string_literal: true
#
# Cookbook Name:: opsworks_ruby
# Spec:: configure
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'opsworks_ruby::configure' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |solo_node|
      solo_node.set['deploy'] = node['deploy']
    end.converge(described_recipe)
  end
  before do
    stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app])
    stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([aws_opsworks_rds_db_instance])
    stub_node { |n| n.merge(node) }
  end

  context 'Database' do
    context 'Postgresql' do
      it 'creates proper database.yml template' do
        db_config = Drivers::Db::Postgresql.new(aws_opsworks_app, node, rds: aws_opsworks_rds_db_instance).out
        expect(chef_run)
          .to render_file("/srv/www/#{aws_opsworks_app['shortname']}/shared/config/database.yml").with_content(
            JSON.parse({ development: db_config, production: db_config }.to_json).to_yaml
          )
      end
    end
  end
end
