# frozen_string_literal: true
# rubocop:disable Metrics/MethodLength
def node(override = {})
  item = {
    deploy: {
      dummy_project: {
        database: {
          adapter: 'postgresql',
          username: 'dbuser',
          password: '03c1bc98cdd5eb2f9c75',
          host: 'dummy-project.c298jfowejf.us-west-2.rds.amazon.com',
          database: 'dummydb',
          reaping_frequency: 10
        }
      }
    }
  }.merge(override)

  JSON.parse(item.to_json)
end
# rubocop:enable Metrics/MethodLength
