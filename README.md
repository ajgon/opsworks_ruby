# opsworks_ruby Cookbook

[![Chef cookbook](https://img.shields.io/cookbook/v/opsworks_ruby.svg)](https://supermarket.chef.io/cookbooks/opsworks_ruby)
[![Build Status](https://travis-ci.org/ajgon/opsworks_ruby.svg?branch=master)](https://travis-ci.org/ajgon/opsworks_ruby)
[![Coverage Status](https://coveralls.io/repos/github/ajgon/opsworks_ruby/badge.svg?branch=master)](https://coveralls.io/github/ajgon/opsworks_ruby?branch=master)
[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/)
[![license](https://img.shields.io/github/license/ajgon/opsworks_ruby.svg?maxAge=2592000)](https://opsworks-ruby.mit-license.org/)

A [chef](https://www.chef.io/) cookbook to deploy Ruby applications to Amazon OpsWorks.

## Quick Start

This cookbook is designed to "just work". So in base case scenario, all you have
to do is create a layer and application with an optional assigned RDS data source,
then [add recipes to the corresponding OpsWorks actions](#recipes).

## Support

* Database
  * MariaDB
  * MySQL
  * PostgreSQL
  * Sqlite3
* SCM
  * git
* Framework
  * Ruby on Rails
* App server
  * Unicorn
* Web server
  * nginx
* Worker
  * Null (no worker)
  * sidekiq

## Requirements

### Cookbooks

* [build-essential (~> 2.0)](https://supermarket.chef.io/cookbooks/build-essential)
* [deployer](https://supermarket.chef.io/cookbooks/deployer)
* [ruby-ng](https://supermarket.chef.io/cookbooks/ruby-ng)
* [nginx (~> 2.7)](https://supermarket.chef.io/cookbooks/nginx)

### Platform

This cookbook was tested on the following OpsWorks platforms:

* Amazon Linux 2016.03
* Amazon Linux 2015.09
* Amazon Linux 2015.03
* Ubuntu 14.04 LTS
* Ubuntu 12.04 LTS

In addition, all recent Debian family distrubutions are assumed to work.

## Attributes

Attributes format follows the guidelines of old Chef 11.x based OpsWorks stack.
So all of them, need to be placed under `node['deploy'][<application_shortname>]`.
Attributes (and whole logic of this cookbook) are divided to six sections.
Following convention is used: `app == node['deploy'][<application_shortname>]`
so for example `app['framework']['adapter']` actually means
`node['deploy'][<application_shortname>]['framework']['adapter']`.

### basic

* `node['applications']`
  * An array of application shortnames which should be deployed to given layer.
    If not provided, all detected applications will be deployed.

### global

Global parameters apply to the whole application, and can be used by any section
(framework, appserver etc.).

* `app['environment']`
  * **Default:** `production`
  * Sets the "deploy environment" for all the app-related (for example `RAILS_ENV`
    in Rails) actions in the project (server, worker, etc.)

### database

Those parameters will be passed without any alteration to the `database.yml`
file. Keep in mind, that if you have RDS connected to your OpsWorks application,
you don't need to use them. The chef will do all the job, and determine them
for you.

* `app['database']['adapter']`
  * **Supported values:** `mariadb`, `mysql`, `postgresql`, `sqlite3`
  * **Default:** `sqlite3`
  * ActiveRecord adapter which will be used for database connection.
* `app['database']['username']`
  * Username used to authenticate to the DB
* `app['database']['password']`
  * Password used to authenticate to the DB
* `app['database']['host']`
  * Database host
* `app['database']['database']`
  * Database name
* `app['database'][<any other>]`
  * Any other key-value pair provided here, will be passed directly to the
    `database.yml`

### scm

Those parameters can also be determined from OpsWorks application, and usually
you don't need to provide them here. Currently only `git` is supported.

* `app['scm']['scm_provider']`
  * **Supported values:** `git`
  * **Default:** `git`
  * SCM used by the cookbook to clone the repo.
* `app['scm']['remove_scm_files']`
  * **Supported values:** `true`, `false`
  * **Default:** `true`
  * If set to true, all SCM leftovers (like `.git`) will be removed.
* `app['scm']['repository']`
  * Repository URL
* `app['scm']['revision']`
  * Branch name/SHA1 of commit which should be use as a base of the deployment.
* `app['scm']['ssh_key']`
  * A private SSH deploy key (the key itself, not the file name), used when
    fetching repositories via SSH.
* `app['scm']['ssh_wrapper']`
  * A wrapper script, which will be used by git when fetching repository
    via SSH. Essentially, a value of `GIT_SSH` environment variable. This
    cookbook provides one of those scripts for you, so you shouldn't alter this
    variable unless you know what you're doing.
* `app['scm']['enabled_submodules']`
  * If set to `true`, any submodules included in the repository, will also be
    fetched.

### framework

Pre-optimalization for specific frameworks (like migrations, cache etc.).
Currently only `Rails` is supported.

* `app['framework']['adapter']`
  * **Supported values:** `rails`
  * **Default:** `rails`
  * Ruby framework used in project.
* `app['framework']['migrate']`
  * **Supported values:** `true`, `false`
  * **Default:** `true`
  * If set to `true`, migrations will be launch during deployment.
* `app['framework']['migration_command']`
  * A command which will be invoked to perform migration. This cookbook comes
    with predefined migration commands, well suited for the task, and usually
    you don't have to change this parameter.
* `app['framework']['assets_precompile']`
  * **Supported values:** `true`, `false`
  * **Default:** `true`
* `app['framework']['assets_precompilation_command']`
  * A command which will be invoked to precompile assets.

### appserver

Configuration parameters for the ruby application server. Currently only
`Unicorn` is supported.

* `app['appserver']['adapter']`
  * **Default:** `unicorn`
  * **Supported values:** `unicorn`, `null`
  * Server on the application side, which will receive requests from webserver
    in front. `null` means no appserver enabled.
* [`app['appserver']['accept_filter']`](https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen)
  * **Default:** `httpready`
* `app['appserver']['application_yml']`
  * **Supported values:** `true`, `false`
  * **Default:** `false`
  * Creates a `config/application.yml` file with all pre-configured environment
    variables. Useful for gems like [figaro](https://github.com/laserlemon/figaro)
* [`app['appserver']['backlog']`](https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen)
  * **Default:** `1024`
* [`app['appserver']['delay']`](https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen)
  * **Default:** `0.5`
* `app['appserver']['dot_env']`
  * **Supported values:** `true`, `false`
  * **Default:** `false`
  * Creates a `.env` file with all pre-configured environment
    variables. Useful for gems like [dotenv](https://github.com/bkeepers/dotenv)
* [`app['appserver']['preload_app']`](https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-preload_app)
  * **Supported values:** `true`, `false`
  * **Default:** `true`
* [`app['appserver']['tcp_nodelay']`](https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen)
  * **Supported values:** `true`, `false`
  * **Default:** `true`
* [`app['appserver']['tcp_nopush']`](https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen)
  * **Supported values:** `true`, `false`
  * **Default:** `false`
* [`app['appserver']['tries']`](https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen)
  * **Default:** `5`
* [`app['appserver']['timeout']`](https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-timeout)
  * **Default:** `50`
* [`app['appserver']['worker_processes']`](https://unicorn.bogomips.org/TUNING.html)
  * **Default:** `4`

### webserver

Webserver configuration. Proxy passing to application is handled out-of-the-box.
Currently only nginx is supported.

* `app['webserver']['adapter']`
  * **Default:** `nginx`
  * **Supported values:** `nginx`, `null`
  * Webserver in front of the instance. It runs on port 80,
    and receives all requests from Load Balancer/Internet.
    `null` means no webserver enabled.
* `app['webserver']['build_type']`
  * **Supported values:** `default` or `source`
  * **Default:** `default`
  * The way the [nginx](https://supermarket.chef.io/cookbooks/nginx) cookbooks
    handles `nginx` installation. Check out [the corresponding docs](https://github.com/miketheman/nginx/tree/2.7.x#recipes)
    for more details. Never use `node['nginx']['install_method']`, as it will
    be always overwritten by this attribute.
* [`app['webserver']['client_body_timeout']`](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_body_timeout)
  * **Default:** `12`
* [`app['webserver']['client_header_timeout']`](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_header_timeout)
  * **Default:** `12`
* [`app['webserver']['client_max_body_size']`](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size)
  * **Default:** `10m`
* `app['webserver']['dhparams']`
  * If you wish to use custom generated DH primes, instead of common ones
    (which is a very good practice), put the contents (not file name) of the
    `dhparams.pem` file into this attribute. [Read more here.](https://weakdh.org/sysadmin.html)
* `app['webserver']['extra_config']`
  * Raw nginx configuration, which will be inserted into `server` section of the
    application for HTTP port.
* `app['webserver']['extra_config_ssl']`
  * Raw nginx configuration, which will be inserted into `server` section of the
    application for HTTPS port. If set to `true`, the `extra_config` will be copied.
* [`app['webserver']['keepalive_timeout']`](http://nginx.org/en/docs/http/ngx_http_core_module.html#keepalive_timeout)
  * **Default**: `15`
* `app['webserver']['log_dir']`
  * **Default**: `/var/log/nginx`
  * A place to store application-related nginx logs.
* [`app['webserver']['proxy_read_timeout']`](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_read_timeout)
  * **Default**: `60`
* [`app['webserver']['proxy_send_timeout']`](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_send_timeout)
  * **Default**: `60`
* [`app['webserver']['send_timeout']`](http://nginx.org/en/docs/http/ngx_http_core_module.html#send_timeout)
  * **Default**: `10`
* `app['webserver']['ssl_for_legacy_browsers']`
  * **Supported values:** `true`, `false`
  * **Default:** `false`
  * By default nginx is configured to follow strict SSL security standards,
    [covered in this article](https://cipherli.st/). However, old browsers
    (like IE < 9 or Android < 2.2) wouldn't work with this configuration very
    well. If your application needs a support for those browsers, set this
    parameter to `true`.

Since this driver is basically a wrapper for [nginx cookbook](https://github.com/miketheman/nginx/tree/2.7.x),
you can also configure [`node['nginx']` attributes](https://github.com/miketheman/nginx/tree/2.7.x#attributes)
as well (notice that `node['deploy'][<application_shortname>]` logic doesn't
apply here.)

### worker

Configuration for ruby workers. Currenty `Null` (no worker) and `Sidekiq`
are supported. Every worker is covered by `monitd` daemon out-of-the-box.

* `app['worker']['adapter']`
  * **Default:** `null`
  * **Supported values:** `null`, `sidekiq`
  * Worker used to perform background tasks. `null` means no worker enabled.
* `app['worker']['process_count']`
  * ** Default:** `2`
  * How many separate worker processes will be launched.
* `app['worker']['syslog']`
  * **Default:** `true`
  * **Supported values:** `true`, `false`
  * Log worker output to syslog?
* `app['worker']['config']`
  * Configuration parameters which will be directly passed to the worker.
    For example, for `sidekiq` they will be serialized to
    [`sidekiq.yml` config file](https://github.com/mperham/sidekiq/wiki/Advanced-Options#the-sidekiq-configuration-file).

## Recipes

This cookbook provides five main recipes, which should be attached
to corresponding OpsWorks actions.

* `opsworks_ruby::setup` - attach to **Setup**
* `opsworks_ruby::configure` - attach to **Configure**
* `opsworks_ruby::deploy` - attach to **Deploy**
* `opsworks_ruby::undeploy` - attach to **Undeploy**
* `opsworks_ruby::shutdown` - attach to **Shutdown**

## Contributing

Please see [CONTRIBUTING](https://github.com/ajgon/opsworks_ruby/blob/master/CONTRIBUTING.md)
for details.

## Author and Contributors

Author: Igor Rzegocki <[igor@rzegocki.pl](mailto:igor@rzegocki.pl)>

### Contributors

* Phong Si ([@phongsi](https://github.com/phongsi))
* Nathan Flood ([@npflood](https://github.com/npflood))
* Marcos Beirigo ([@marcosbeirigo](https://github.com/marcosbeirigo))

## License

License: [MIT](http://opsworks-ruby.mit-license.org/)
