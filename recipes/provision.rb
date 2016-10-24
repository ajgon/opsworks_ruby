# frozen_string_literal: true
# Used for tests, don't touch!

file '/etc/monit/conf.d/00_httpd.monitrc' do
  content "set httpd port 2812 and\n    use address localhost\n    allow localhost"
end
