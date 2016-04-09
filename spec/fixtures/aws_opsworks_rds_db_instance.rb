# frozen_string_literal: true
# rubocop:disable Metrics/MethodLength
def aws_opsworks_rds_db_instance(override = {})
  item = {
    rds_db_instance_arn: 'arn:aws:rds:us-west-2:850906259207:db:dummy-project',
    db_instance_identifier: 'dummy-project',
    db_user: 'dbuser',
    db_password: '03c1bc98cdd5eb2f9c75',
    region: 'us-west-2',
    address: 'dummy-project.c298jfowejf.us-west-2.rds.amazon.com',
    engine: 'postgres',
    missing_on_rds: false,
    id: 'arn_aws_rds_us-west-2_850906259207_db_dummy-project'
  }.merge(override)

  JSON.parse(item.to_json)
end
# rubocop:enable Metrics/MethodLength
