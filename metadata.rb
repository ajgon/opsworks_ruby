# frozen_string_literal: true
name 'opsworks_ruby'
maintainer 'Igor Rzegocki'
maintainer_email 'igor@rzegocki.pl'
license 'MIT'
description 'Set of chef recipes for OpsWorks based Ruby projects'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.4.0'

depends 'deployer'
depends 'rvm', '~> 0.9'
depends 'chef_nginx'

supports 'amazon', '>= 2015.03'
supports 'ubuntu', '>= 12.04'

source_url 'https://github.com/ajgon/opsworks_ruby'
issues_url 'https://github.com/ajgon/opsworks_ruby/issues'
