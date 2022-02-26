# frozen_string_literal: true

require 'json'

bag_file = File.expand_path('data_bags/s3_thin_nginx_padrino_delayed_job/aws_opsworks_app/dummy_project.json', __dir__)

data_bag = JSON.parse(File.read(bag_file))
data_bag['app_source']['user'] = ENV.fetch('AWS_ACCESS_KEY_ID', nil)
data_bag['app_source']['password'] = ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
File.write(bag_file, data_bag.to_json)
