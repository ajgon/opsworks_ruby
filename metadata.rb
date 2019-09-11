# frozen_string_literal: true

name 'opsworks_ruby'
maintainer 'Igor Rzegocki'
maintainer_email 'igor@rzegocki.pl'
license 'MIT'
description 'Set of chef recipes for OpsWorks based Ruby projects'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.15.0'
chef_version '>= 12.0' if respond_to?(:chef_version)

depends 'apt', '< 7.0'
depends 'chef_client_updater'
depends 'deploy_resource'
depends 'logrotate'
depends 'nginx', '< 9.0'
depends 'nodejs'
depends 'ohai', '< 5.3'
depends 'ruby-ng'
depends 's3_file'
depends 'sudo'
depends 'yarn'

# indirect dependency, but breaks against the chef_version if updated to 3.1.0
depends 'seven_zip', '~> 2.0'
# indirect dependency required to maintain compatibility with chef 12
depends 'windows', '< 5.0'

supports 'amazon', '>= 2017.03'
supports 'ubuntu', '>= 16.04'

source_url 'https://github.com/ajgon/opsworks_ruby'
issues_url 'https://github.com/ajgon/opsworks_ruby/issues'
