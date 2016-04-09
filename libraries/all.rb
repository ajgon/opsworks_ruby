libdir = File.expand_path('..', __FILE__)
require File.join(libdir, 'core_ext')
Dir[File.join(libdir, '*', '**', '*.rb')].each { |f| require f }
