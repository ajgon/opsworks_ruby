# frozen_string_literal: true

require 'json'

bag_file = File.expand_path('data_bags/s3_thin_nginx_padrino_delayed_job/aws_opsworks_app/dummy_project.json', __dir__)

data_bag = JSON.parse(File.read(bag_file))
data_bag['app_source']['user'] = ENV['AWS_ACCESS_KEY_ID']
data_bag['app_source']['password'] = ENV['AWS_SECRET_ACCESS_KEY']
File.write(bag_file, data_bag.to_json)
