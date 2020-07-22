# frozen_string_literal: true

libdir = File.expand_path(__dir__)
require File.join(libdir, 'core_ext')
require File.join(libdir, 'helpers')
require File.join(libdir, 'archive')
require File.join(libdir, 'chef_patches')

# resource_deploy
Dir[File.join(libdir, 'provider_*.rb')].sort.each { |f| require f }
Dir[File.join(libdir, 'resource_*.rb')].sort.each { |f| require f }

require File.join(libdir, 'drivers_base.rb')
Dir[File.join(libdir, 'drivers_dsl_*.rb')].sort.each { |f| require f }

require File.join(libdir, 'drivers_source_base.rb')
Dir[File.join(libdir, 'drivers_*_base.rb')].sort.each { |f| require f }
Dir[File.join(libdir, 'drivers_appserver_*.rb')].sort.each { |f| require f }
Dir[File.join(libdir, 'drivers_db_*.rb')].sort.each { |f| require f }
Dir[File.join(libdir, 'drivers_framework_*.rb')].sort.each { |f| require f }
Dir[File.join(libdir, 'drivers_source_*.rb')].sort.each { |f| require f }
Dir[File.join(libdir, 'drivers_webserver_*.rb')].sort.each { |f| require f }
Dir[File.join(libdir, 'drivers_worker_*.rb')].sort.each { |f| require f }
