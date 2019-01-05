# frozen_string_literal: true

libdir = File.expand_path(__dir__)
require File.join(libdir, 'core_ext')
require File.join(libdir, 'helpers')
require File.join(libdir, 'archive')
require File.join(libdir, 'chef_patches')
Dir[File.join(libdir, 'drivers_base.rb')].each { |f| require f }
Dir[File.join(libdir, 'drivers_dsl_*.rb')].each { |f| require f }
Dir[File.join(libdir, 'drivers_source_base.rb')].each { |f| require f }
Dir[File.join(libdir, 'drivers_*_base.rb')].each { |f| require f }
Dir[File.join(libdir, 'drivers_appserver_*.rb')].each { |f| require f }
Dir[File.join(libdir, 'drivers_db_*.rb')].each { |f| require f }
Dir[File.join(libdir, 'drivers_framework_*.rb')].each { |f| require f }
Dir[File.join(libdir, 'drivers_source_*.rb')].each { |f| require f }
Dir[File.join(libdir, 'drivers_webserver_*.rb')].each { |f| require f }
Dir[File.join(libdir, 'drivers_worker_*.rb')].each { |f| require f }
