# frozen_string_literal: true

#
# Cookbook Name:: opsworks_ruby
# Spec:: default

require 'spec_helper'

describe 'opsworks_ruby::setup' do
  let(:chef_runner) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
      solo_node.set['deploy'] = node['deploy']
      solo_node.set['lsb'] = node['lsb']
    end
  end
  let(:chef_run) do
    chef_runner.converge(described_recipe)
  end
  let(:chef_runner_rhel) do
    ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
      solo_node.set['deploy'] = node['deploy']
    end
  end
  let(:chef_run_rhel) do
    chef_runner_rhel.converge(described_recipe)
  end

  before do
    stub_search(:aws_opsworks_app, '*:*').and_return([aws_opsworks_app])
    stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([aws_opsworks_rds_db_instance])
    stub_node { |n| n.merge(node) }
    stub_command('which nginx').and_return(false)
  end

  context 'Chef version' do
    it 'not set' do
      expect(chef_run).not_to create_directory('/opt/aws/opsworks/current/plugins')
    end

    it 'set to false' do
      chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        solo_node.set['chef-version'] = false
      end.converge(described_recipe)

      expect(chef_run).not_to create_directory('/opt/aws/opsworks/current/plugins')
    end

    it 'set to 14' do
      chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        solo_node.set['chef-version'] = '14'
      end.converge(described_recipe)

      expect(chef_run).to create_directory('/opt/aws/opsworks/current/plugins').with(
        owner: 'root',
        group: 'aws',
        mode: '0755',
        recursive: true
      )
      expect(chef_run).to create_cookbook_file('/opt/aws/opsworks/current/plugins/debian_downgrade_protection.rb').with(
        source: 'debian_downgrade_protection.rb',
        owner: 'root',
        group: 'aws',
        mode: '0644'
      )
      expect(chef_run).to update_chef_client_updater('update chef-client')
    end
  end

  context 'Deployer' do
    it 'debian user' do
      expect(chef_run).to create_group('deploy').with(gid: 5000)
      expect(chef_run).to create_user('deploy').with(
        comment: 'The deployment user',
        uid: 5000,
        gid: 5000,
        home: '/home/deploy'
      )
    end

    it 'rhel user' do
      expect(chef_run).to create_group('deploy').with(gid: 5000)
      expect(chef_run).to create_user('deploy').with(
        comment: 'The deployment user',
        uid: 5000,
        gid: 5000,
        home: '/home/deploy'
      )
    end
  end

  context 'Ruby fullstaq' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        solo_node.set['ruby'] = { 'version' => '2.6' }
        solo_node.set['lsb'] = node['lsb']
        solo_node.set['deploy'] = node['deploy']
        solo_node.set['ruby-provider'] = 'fullstaq'
      end.converge(described_recipe)
    end

    let(:expected_path) do
      '/usr/lib/fullstaq-ruby/versions/2.6/bin:' \
      '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games'
    end

    it 'install gnupg2' do
      expect(chef_run).to install_package('gnupg2')
    end

    it 'updates environment path' do
      expect(chef_run).to create_template('/etc/environment').with_source('environment.erb')
      expect(chef_run).to render_file('/etc/environment').with_content("PATH=\"#{expected_path}\"")
    end

    it 'updates bundler' do
      expect(chef_run).to run_execute('update bundler').with(
        command: '/usr/lib/fullstaq-ruby/versions/2.6/bin/gem update bundler',
        user: 'root',
        environment: { 'PATH' => expected_path }
      )

      expect(chef_run).to create_link('/usr/local/bin/bundle').with(
        to: '/usr/lib/fullstaq-ruby/versions/2.6/bin/bundle'
      )
    end

    it 'links ruby' do
      expect(chef_run).to create_link('/usr/local/bin/ruby').with(
        to: '/usr/lib/fullstaq-ruby/versions/2.6/bin/ruby'
      )
    end

    context 'Debian' do
      it 'installs ruby 2.5' do
        chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.5' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
          solo_node.set['ruby-provider'] = 'fullstaq'
        end.converge(described_recipe)

        expect(chef_run).to install_package('fullstaq-ruby-2.5')
      end

      it 'installs ruby 2.5 with variant' do
        chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.5' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
          solo_node.set['ruby-provider'] = 'fullstaq'
          solo_node.set['ruby-variant'] = 'jemalloc'
        end.converge(described_recipe)

        expect(chef_run).to install_package('fullstaq-ruby-2.5-jemalloc')
      end

      it 'installs ruby 2.6' do
        expect(chef_run).to install_package('fullstaq-ruby-2.6')
      end

      it 'installs ruby 2.6 with variant' do
        chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.6' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
          solo_node.set['ruby-provider'] = 'fullstaq'
          solo_node.set['ruby-variant'] = 'jemalloc'
        end.converge(described_recipe)

        expect(chef_run).to install_package('fullstaq-ruby-2.6-jemalloc')
      end

      it 'adds fullstaq apt repository' do
        keyurl = 'https://raw.githubusercontent.com/fullstaq-labs/fullstaq-ruby-server-edition/master/fullstaq-ruby.asc'

        expect(chef_run).to add_apt_repository('fullstaq-ruby').with(
          uri: 'https://apt.fullstaqruby.org',
          distribution: 'ubuntu-14.04',
          components: %w[main]
        )
        expect(chef_run).to create_remote_file(
          "#{Chef::Config[:file_cache_path]}/fullstaq-ruby.asc"
        ).with(source: keyurl)
        expect(chef_run).to run_execute('add fullstaq repository key').with(
          command: "apt-key add #{Chef::Config[:file_cache_path]}/fullstaq-ruby.asc",
          user: 'root'
        )
      end
    end

    context 'rhel' do
      let(:chef_run_rhel) do
        ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.6' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
          solo_node.set['ruby-provider'] = 'fullstaq'
        end.converge(described_recipe)
      end

      it 'installs ruby 2.5' do
        chef_run_rhel = ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.5' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
          solo_node.set['ruby-provider'] = 'fullstaq'
        end.converge(described_recipe)

        expect(chef_run_rhel).to install_package('fullstaq-ruby-2.5')
      end

      it 'installs ruby 2.5 with variant' do
        chef_run_rhel = ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.5' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
          solo_node.set['ruby-provider'] = 'fullstaq'
          solo_node.set['ruby-variant'] = 'jemalloc'
        end.converge(described_recipe)

        expect(chef_run_rhel).to install_package('fullstaq-ruby-2.5-jemalloc')
      end

      it 'installs ruby 2.6' do
        expect(chef_run_rhel).to install_package('fullstaq-ruby-2.6')
      end

      it 'installs ruby 2.6 with variant' do
        chef_run_rhel = ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.6' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
          solo_node.set['ruby-provider'] = 'fullstaq'
          solo_node.set['ruby-variant'] = 'jemalloc'
        end.converge(described_recipe)

        expect(chef_run_rhel).to install_package('fullstaq-ruby-2.6-jemalloc')
      end

      it 'adds fullstaq yum repository' do
        expect(chef_run_rhel).to create_yum_repository('fullstaq-ruby').with(
          baseurl: 'https://yum.fullstaqruby.org/centos-7/$basearch',
          enabled: true,
          gpgcheck: false,
          gpgkey: 'https://raw.githubusercontent.com/fullstaq-labs/fullstaq-ruby-server-edition/master/fullstaq-ruby.asc',
          repo_gpgcheck: true,
          sslverify: true
        )
      end
    end
  end

  context 'Rubies' do
    context 'Debian' do
      context 'ruby-ng' do
        it 'installs ruby 2.0' do
          chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
            solo_node.set['ruby'] = { 'version' => '2.0' }
            solo_node.set['lsb'] = node['lsb']
            solo_node.set['deploy'] = node['deploy']
          end.converge(described_recipe)

          expect(chef_run).to install_package('ruby2.0')
          expect(chef_run).to install_package('ruby2.0-dev')
        end

        it 'installs ruby 2.1' do
          chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
            solo_node.set['ruby'] = { 'version' => '2.1' }
            solo_node.set['lsb'] = node['lsb']
            solo_node.set['deploy'] = node['deploy']
          end.converge(described_recipe)

          expect(chef_run).to install_package('ruby2.1')
          expect(chef_run).to install_package('ruby2.1-dev')
        end

        it 'installs ruby 2.2' do
          chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
            solo_node.set['ruby'] = { 'version' => '2.2' }
            solo_node.set['lsb'] = node['lsb']
            solo_node.set['deploy'] = node['deploy']
          end.converge(described_recipe)

          expect(chef_run).to install_package('ruby2.2')
          expect(chef_run).to install_package('ruby2.2-dev')
        end

        it 'installs ruby 2.3' do
          chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
            solo_node.set['ruby'] = { 'version' => '2.3' }
            solo_node.set['lsb'] = node['lsb']
            solo_node.set['deploy'] = node['deploy']
          end.converge(described_recipe)

          expect(chef_run).to install_package('ruby2.3')
          expect(chef_run).to install_package('ruby2.3-dev')
        end

        it 'installs ruby 2.4' do
          chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
            solo_node.set['ruby'] = { 'version' => '2.4' }
            solo_node.set['lsb'] = node['lsb']
            solo_node.set['deploy'] = node['deploy']
          end.converge(described_recipe)

          expect(chef_run).to install_package('ruby2.4')
          expect(chef_run).to install_package('ruby2.4-dev')
        end

        it 'installs ruby 2.5' do
          chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
            solo_node.set['ruby'] = { 'version' => '2.5' }
            solo_node.set['lsb'] = node['lsb']
            solo_node.set['deploy'] = node['deploy']
          end.converge(described_recipe)

          expect(chef_run).to install_package('ruby2.5')
          expect(chef_run).to install_package('ruby2.5-dev')
        end

        it 'installs ruby 2.6' do
          expect(chef_run).to install_package('ruby2.6')
          expect(chef_run).to install_package('ruby2.6-dev')
        end
      end
    end

    context 'rhel' do
      it 'installs ruby 2.0' do
        chef_run_rhel = ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.0' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
        end.converge(described_recipe)

        expect(chef_run_rhel).to install_package('ruby20')
        expect(chef_run_rhel).to install_package('ruby20-devel')
        expect(chef_run_rhel).to run_execute('/usr/sbin/alternatives --set ruby /usr/bin/ruby2.0')
      end

      it 'installs ruby 2.1' do
        chef_run_rhel = ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.1' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
        end.converge(described_recipe)

        expect(chef_run_rhel).to install_package('ruby21')
        expect(chef_run_rhel).to install_package('ruby21-devel')
        expect(chef_run_rhel).to run_execute('/usr/sbin/alternatives --set ruby /usr/bin/ruby2.1')
      end

      it 'installs ruby 2.2' do
        chef_run_rhel = ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.2' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
        end.converge(described_recipe)

        expect(chef_run_rhel).to install_package('ruby22')
        expect(chef_run_rhel).to install_package('ruby22-devel')
        expect(chef_run_rhel).to run_execute('/usr/sbin/alternatives --set ruby /usr/bin/ruby2.2')
      end

      it 'installs ruby 2.3' do
        chef_run_rhel = ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.3' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
        end.converge(described_recipe)

        expect(chef_run_rhel).to install_package('ruby23')
        expect(chef_run_rhel).to install_package('ruby23-devel')
        expect(chef_run_rhel).to run_execute('/usr/sbin/alternatives --set ruby /usr/bin/ruby2.3')
      end

      it 'installs ruby 2.4' do
        chef_run_rhel = ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.4' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
        end.converge(described_recipe)

        expect(chef_run_rhel).to install_package('ruby24')
        expect(chef_run_rhel).to install_package('ruby24-devel')
        expect(chef_run_rhel).to run_execute('/usr/sbin/alternatives --set ruby /usr/bin/ruby2.4')
      end

      it 'installs ruby 2.5' do
        chef_run_rhel = ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
          solo_node.set['ruby'] = { 'version' => '2.5' }
          solo_node.set['lsb'] = node['lsb']
          solo_node.set['deploy'] = node['deploy']
        end.converge(described_recipe)

        expect(chef_run_rhel).to install_package('ruby25')
        expect(chef_run_rhel).to install_package('ruby25-devel')
        expect(chef_run_rhel).to run_execute('/usr/sbin/alternatives --set ruby /usr/bin/ruby2.5')
      end

      it 'installs ruby 2.6' do
        expect(chef_run_rhel).to install_package('ruby26')
        expect(chef_run_rhel).to install_package('ruby26-devel')
        expect(chef_run_rhel).to run_execute('/usr/sbin/alternatives --set ruby /usr/bin/ruby2.6')
      end
    end
  end

  context 'Gems' do
    context 'when rubygems version is < 3' do
      before do
        stub_const('Gem::VERSION', '2.7.8')
      end

      it 'debian bundler' do
        expect(chef_run).to install_gem_package(:bundler).with(version: '~> 1')
        expect(chef_run).to create_link('/usr/local/bin/bundle').with(to: '/usr/bin/bundle')
      end

      it 'rhel bundler' do
        expect(chef_run_rhel).to install_gem_package(:bundler).with(version: '~> 1')
        expect(chef_run_rhel).to create_link('/usr/local/bin/bundle').with(to: '/usr/local/bin/bundler')
      end
    end

    context 'when rubygems version is >= 3' do
      before do
        stub_const('Gem::VERSION', '3.0.2')
      end

      it 'debian bundler' do
        expect(chef_run).to install_gem_package(:bundler)
        expect(chef_run).not_to install_gem_package(:bundler).with(version: '~> 1')
        expect(chef_run).to create_link('/usr/local/bin/bundle').with(to: '/usr/bin/bundle')
      end

      it 'rhel bundler' do
        expect(chef_run_rhel).to install_gem_package(:bundler)
        expect(chef_run_rhel).not_to install_gem_package(:bundler).with(version: '~> 1')
        expect(chef_run_rhel).to create_link('/usr/local/bin/bundle').with(to: '/usr/local/bin/bundler')
      end
    end
  end

  context 'debian preparations' do
    it 'javascript-common' do
      expect(chef_run).to purge_apt_package('javascript-common')
    end

    it 'monit' do
      expect(chef_run).to run_execute('mkdir -p /etc/monit/conf.d')
      expect(chef_run).to create_file('/etc/monit/conf.d/00_httpd.monitrc').with(
        content: "set httpd port 2812 and\n    use address localhost\n    allow localhost"
      )
    end
  end

  context 'epel' do
    it 'rhel' do
      expect(chef_run_rhel).to run_execute('yum-config-manager --enable epel')
    end
  end

  context 'apt_repository' do
    context 'debian' do
      it 'installs the PPA apt repository for Apache2' do
        expect(chef_run).to add_apt_repository('apache2')
      end

      context 'when use_apache2_ppa is set to false' do
        before do
          chef_runner.node.set['defaults']['webserver']['use_apache2_ppa'] = false
        end

        it 'does not installl the PPA apt repository for Apache2' do
          expect(chef_run).not_to add_apt_repository('apache2')
        end
      end
    end

    context 'rhel' do
      it 'does not install the PPA apt repository for Apache2' do
        expect(chef_run_rhel).not_to add_apt_repository('apache2')
      end
    end
  end

  context 'Postgresql + git + nginx + sidekiq' do
    it 'installs required packages for debian' do
      expect(chef_run).to install_package('nginx')
      expect(chef_run).to install_package('zlib1g-dev')
      expect(chef_run).to install_package('git')
      expect(chef_run).to install_package('libpq-dev')
      expect(chef_run).to install_package('redis-server')
      expect(chef_run).to install_package('monit')
      expect(chef_run).to install_package('tzdata')
      expect(chef_run).to install_package('libxml2-dev')
    end

    it 'installs required packages for rhel' do
      expect(chef_run_rhel).to install_package('nginx')
      expect(chef_run_rhel).to install_package('zlib-devel')
      expect(chef_run_rhel).to install_package('git')
      expect(chef_run_rhel).to install_package('postgresql96-devel')
      expect(chef_run_rhel).to install_package('redis')
      expect(chef_run_rhel).to install_package('monit')
      expect(chef_run_rhel).to install_package('tzdata')
      expect(chef_run_rhel).to install_package('libxml2-devel')
    end

    it 'defines service which starts nginx' do
      expect(chef_run).to start_service('nginx')
    end
  end

  context 'Mysql + S3 + apache2 + resque' do
    ALL_APACHE2_MODULES = %w[expires headers lbmethod_byrequests proxy proxy_balancer proxy_http rewrite ssl].freeze
    let(:modules_already_enabled) { false }

    before do
      stub_search(:aws_opsworks_app, '*:*')
        .and_return([aws_opsworks_app(app_source: { type: 's3', url: 'http://example.com' })])
      stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([aws_opsworks_rds_db_instance(engine: 'mysql')])
      ALL_APACHE2_MODULES.each do |mod|
        stub_command("a2enmod #{mod}").and_return(true)
        stub_command("a2query -m #{mod}").and_return(modules_already_enabled)
      end
    end

    let(:chef_runner) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        deploy = node['deploy']
        deploy['dummy_project']['webserver']['adapter'] = 'apache2'
        deploy['dummy_project']['worker']['adapter'] = 'resque'
        deploy['dummy_project']['source'] = {}
        solo_node.set['deploy'] = deploy
      end
    end

    let(:chef_runner_rhel) do
      ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
        deploy = node['deploy']
        deploy['dummy_project']['webserver']['adapter'] = 'apache2'
        deploy['dummy_project']['worker']['adapter'] = 'resque'
        deploy['dummy_project']['source'] = {}
        solo_node.set['deploy'] = deploy
      end
    end

    context 'debian' do
      it 'installs required packages' do
        expect(chef_run).to install_package('apache2')
        expect(chef_run).to install_package('bzip2')
        expect(chef_run).to install_package('git')
        expect(chef_run).to install_package('gzip')
        expect(chef_run).not_to install_package('libapache2-mod-passenger')
        expect(chef_run).to install_package('libmysqlclient-dev')
        expect(chef_run).to install_package('monit')
        expect(chef_run).to install_package('p7zip')
        expect(chef_run).to install_package('redis-server')
        expect(chef_run).to install_package('tar')
        expect(chef_run).to install_package('unzip')
        expect(chef_run).to install_package('xz-utils')
      end

      it 'defines service which starts apache2' do
        expect(chef_run).to start_service('apache2')
      end

      ALL_APACHE2_MODULES.each do |mod|
        it "enables Apache2 module #{mod}" do
          expect(chef_run).to run_execute("a2enmod #{mod}")
        end
      end

      context 'when the modules are already enabled' do
        let(:modules_already_enabled) { true }

        ALL_APACHE2_MODULES.each do |mod|
          it "does not enable Apache2 module #{mod} again unnecessarily" do
            expect(chef_run).not_to run_execute("a2enmod #{mod}")
          end
        end
      end
    end

    context 'rhel' do
      it 'installs required packages' do
        expect(chef_run_rhel).to install_package('bzip2')
        expect(chef_run_rhel).to install_package('git')
        expect(chef_run_rhel).to install_package('gzip')
        expect(chef_run_rhel).to install_package('httpd24')
        expect(chef_run_rhel).to install_package('mod24_ssl')
        expect(chef_run_rhel).to install_package('monit')
        expect(chef_run_rhel).to install_package('mysql-devel')
        expect(chef_run_rhel).to install_package('redis')
        expect(chef_run_rhel).to install_package('tar')
        expect(chef_run_rhel).to install_package('unzip')
        expect(chef_run_rhel).to install_package('xz')
      end

      it 'defines service which starts httpd' do
        expect(chef_run_rhel).to start_service('httpd')
      end

      it 'creates sites-* directories' do
        expect(chef_run_rhel).to create_directory('/etc/httpd/sites-available')
        expect(chef_run_rhel).to create_directory('/etc/httpd/sites-enabled')
        expect(chef_run_rhel)
          .to run_execute('echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf')
      end
    end

    context 'passenger' do
      context 'debian' do
        before do
          chef_runner.node.set['deploy']['dummy_project']['appserver']['adapter'] = 'passenger'
          chef_runner.node.set['defaults']['appserver']['passenger_version'] = '1.2.3'
        end

        it 'activates the passenger APT repo' do
          expect(chef_run).to add_apt_repository('passenger')
        end

        it 'installs the libapache2-mod-passenger package' do
          expect(chef_run).to install_package('libapache2-mod-passenger').with_version('1.2.3')
        end
      end

      context 'rhel' do
        before do
          chef_runner_rhel.node.set['deploy']['dummy_project']['appserver']['adapter'] = 'passenger'
        end

        it 'raises an exception' do
          expect { chef_run_rhel }.to raise_error(ArgumentError, 'passenger appserver only supported on Debian/Ubuntu')
        end
      end
    end
  end

  context 'Sqlite + http + delayed_job' do
    temp_node = node['deploy']
    temp_node['dummy_project']['database'] = {}
    temp_node['dummy_project']['database']['adapter'] = 'sqlite'
    temp_node['dummy_project']['worker']['adapter'] = 'delayed_job'
    temp_node['dummy_project']['source'] = {}

    let(:chef_runner) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
        solo_node.set['deploy'] = temp_node
        solo_node.set['lsb'] = node['lsb']
      end
    end
    let(:chef_runner_rhel) do
      ChefSpec::SoloRunner.new(platform: 'amazon', version: '2015.03') do |solo_node|
        solo_node.set['deploy'] = temp_node
      end
    end

    before do
      stub_search(:aws_opsworks_app, '*:*')
        .and_return([aws_opsworks_app(app_source: { type: 'archive', url: 'http://example.com' })])
      stub_search(:aws_opsworks_rds_db_instance, '*:*').and_return([])
    end

    it 'installs required packages for debian' do
      expect(chef_run).to install_package('bzip2')
      expect(chef_run).to install_package('git')
      expect(chef_run).to install_package('gzip')
      expect(chef_run).to install_package('p7zip')
      expect(chef_run).to install_package('tar')
      expect(chef_run).to install_package('unzip')
      expect(chef_run).to install_package('xz-utils')
      expect(chef_run).to install_package('libsqlite3-dev')
      expect(chef_run).to install_package('monit')
    end

    it 'installs required packages for rhel' do
      expect(chef_run_rhel).to install_package('bzip2')
      expect(chef_run_rhel).to install_package('git')
      expect(chef_run_rhel).to install_package('gzip')
      expect(chef_run_rhel).to install_package('monit')
      expect(chef_run_rhel).to install_package('sqlite-devel')
      expect(chef_run_rhel).to install_package('tar')
      expect(chef_run_rhel).to install_package('unzip')
      expect(chef_run_rhel).to install_package('xz')
    end
  end

  it 'empty node[\'deploy\']' do
    chef_run = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |solo_node|
      solo_node.set['lsb'] = node['lsb']
    end.converge(described_recipe)

    expect do
      chef_run
    end.not_to raise_error
  end
end
