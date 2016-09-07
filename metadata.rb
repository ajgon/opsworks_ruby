# frozen_string_literal: true
name 'opsworks_ruby'
maintainer 'Igor Rzegocki'
maintainer_email 'igor@rzegocki.pl'
license 'MIT'
description 'Set of chef recipes for OpsWorks based Ruby projects'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.8.0'

depends 'build-essential', '~> 2.0'
depends 'deployer'
depends 'ruby-ng'
depends 'nginx', '~> 2.7'
depends 'ruby_build'

supports 'amazon', '>= 2015.03'
supports 'ubuntu', '>= 12.04'

source_url 'https://github.com/ajgon/opsworks_ruby'
issues_url 'https://github.com/ajgon/opsworks_ruby/issues'
