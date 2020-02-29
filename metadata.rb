# frozen_string_literal: true

name 'opsworks_ruby'
maintainer 'Igor Rzegocki'
maintainer_email 'igor@rzegocki.pl'
license 'MIT'
description 'Set of chef recipes for OpsWorks based Ruby projects'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.18.0'
chef_version '>= 12.0' if respond_to?(:chef_version)

depends 'apt', '< 7.0'
depends 'ark', '= 4.0.0'
depends 'chef_client_updater', '~> 3.6.0' # 3.7 introduces breaking change
depends 'deploy_resource'
depends 'logrotate', '2.2.1' # 2.2.2 breaks tests for whatever reason
depends 'nginx', '< 9.0'
depends 'nodejs'
depends 'ohai', '< 5.3'
depends 'ruby-ng'
depends 's3_file'
depends 'seven_zip', '~> 2.0'
depends 'sudo', '= 5.4.4'
depends 'windows', '< 5.0'
depends 'yarn'

supports 'amazon', '>= 2017.03'
supports 'ubuntu', '>= 16.04'

source_url 'https://github.com/ajgon/opsworks_ruby'
issues_url 'https://github.com/ajgon/opsworks_ruby/issues'
