# Attributes

Attributes format follows the guidelines of old Chef 11.x based OpsWorks stack. So all of them, need to be placed under
`node['deploy'][<application_shortname>]`. Attributes (and whole logic of this cookbook) are divided to six sections.
Following convention is used: `app == node['deploy'][<application_shortname>]` so for example
`app['framework']['adapter']` actually means `node['deploy'][<application_shortname>]['framework']['adapter']`.

## Stack attributes

These attributes are used on Stack/Layer level globally to configure the opsworks_ruby cookbook itself.
They should'nt be used under ``node['deploy'][<application_shortname>]`` (notice lack of the ``app[]`` convention).

- ``node['applications']``

- An array of application shortnames which should be deployed to given layer. If set, only applications witch ``deploy``
  flag set (on OpsWorks side) included in this list will be deployed. If not set, all ``deploy`` application will be
  supported. This parameter mostly matters during the setup phase, since all application in given stack are deployed
  to the given layer. Using this paramter you can narrow the list to application which you actually intend to use.
  !!! note
      **Important** thing is, that when you try to do a manual deploy from OpsWorks of an application, not included
      in this list - it will be skipped, as this list takes precedence over anything else.

## Application attributes

### global

Global parameters apply to the whole application, and can be used by any section (framework, appserver etc.).

- `app['global']['environment']`
    - **Default:** `production`
    - Sets the "deploy environment" for all the app-related (for example `RAILS_ENV` in Rails) actions in the project
      (server, worker, etc.)

### database

Those parameters will be passed without any alteration to the `database.yml` file. Keep in mind, that if you have RDS
connected to your OpsWorks application, you don't need to use them. The chef will do all the job, and determine them
for you.

- `app['database']['adapter']`
    - **Supported values:** `mariadb`, `mysql`, `postgresql`, `sqlite3`
    - **Default:** `sqlite3`
    - ActiveRecord adapter which will be used for database connection.

- `app['database']['username']`
    - Username used to authenticate to the DB

- `app['database']['password']`
    - Password used to authenticate to the DB

- `app['database']['host']`
    - Database host

- `app['database']['database']`
    - Database name

- `app['database'][<any other>]`
    - Any other key-value pair provided here, will be passed directly to the `database.yml`

### scm

Those parameters can also be determined from OpsWorks application, and usually you don't need to provide them here.
Currently only `git` is supported.

- `app['scm']['scm_provider']`
    - **Supported values:** `git`
    - **Default:** `git`
    - SCM used by the cookbook to clone the repo.

- `app['scm']['remove_scm_files']`
    - **Supported values:** `true`, `false`
    - **Default:** `true`
    - If set to true, all SCM leftovers (like `.git`) will be removed.

- `app['scm']['repository']`
    - Repository URL

- `app['scm']['revision']`
    - Branch name/SHA1 of commit which should be use as a base of the deployment.

- `app['scm']['ssh_key']`
    - A private SSH deploy key (the key itself, not the file name), used when fetching repositories via SSH.

-   `app['scm']['ssh_wrapper']`
    - A wrapper script, which will be used by git when fetching repository via SSH. Essentially, a value of `GIT_SSH`
      environment variable. This cookbook provides one of those scripts for you, so you shouldn't alter this variable
      unless you know what you're doing.

- `app['scm']['enabled_submodules']`
    - If set to `true`, any submodules included in the repository, will also be fetched.

### framework

Pre-optimalization for specific frameworks (like migrations, cache etc.). Currently `hanami.rb` and `Rails`
are supported.

- `app['framework']['adapter']`
    - **Supported values:** `null`, `hanami`, `padrino`, `rails`
    - **Default:** `rails`
    - Ruby framework used in project.

- `app['framework']['migrate']`
    - **Supported values:** `true`, `false`
    - **Default:** `true`
    - If set to `true`, migrations will be launch during deployment.

- `app['framework']['migration_command']`
    - A command which will be invoked to perform migration. This cookbook comes with predefined migration commands,
      well suited for the task, and usually you don't have to change this parameter.

- `app['framework']['assets_precompile']`
    - **Supported values:** `true`, `false`
    - **Default:** `true`

- `app['framework']['assets_precompilation_command']`
    - A command which will be invoked to precompile assets.

#### padrino

For Padrino, slight adjustments needs to be made. Since there are many database adapters supported, instead of creating
configuration for each one, the `DATABASE_URL` environmental variable is provided. You need to parse it in your
`config/database.rb` file and properly pass to the configuration options.

For example, for ActiveRecord:

```ruby
database_url = ENV['DATABASE_URL'] && ActiveRecord::ConnectionAdapters::ConnectionSpecification::ConnectionUrlResolver.new(ENV['DATABASE_URL']).to_hash
ActiveRecord::Base.configurations[:production] = database_url || {
  :adapter => 'sqlite3',
  :database => Padrino.root('db', 'dummy_app_production.db')
}
```

#### rails

- `app['framework']['envs_in_console']`

    !!! warning
        This is highly unstable feature. If you experience any troubles with deployments,
        and have this feature enabled, consider disabling it as a first step in your debugging process.

    - **Supported values:** `true`, `false`
    - **Default:** `false`
    - If set to true, `rails console` will be invoked with all application-level environment variables set.

### appserver

Configuration parameters for the ruby application server. Currently `Puma`, `Thin` and `Unicorn` are supported.

- `app['appserver']['adapter']`
    - **Default:** `puma`
    - **Supported values:** `puma`, `thin`, `unicorn`, `null`
    - Server on the application side, which will receive requests from webserver in front. `null` means no appserver enabled.

- `app['appserver']['application_yml']`
    - **Supported values:** `true`, `false`
    - **Default:** `false`
    - Creates a `config/application.yml` file with all pre-configured environment variables. Useful for gems like
      [figaro](https://github.com/laserlemon/figaro)

- `app['appserver']['dot_env']`
    - **Supported values:** `true`, `false`
    - **Default:** `false`
    - Creates a `.env` file with all pre-configured environment variables. Useful for gems like [dotenv](https://github.com/bkeepers/dotenv)

-   `app['appserver']['preload_app']`
    - **Supported values:** `true`, `false`
    - **Default:** `true`
    - Enabling this preloads an application before forking worker processes.

-   `app['appserver']['timeout']`
    - **Default:** `50`
    - Sets the timeout of worker processes to seconds.

- `app['appserver']['worker_processes']|`
    - **Default:** `4`
    - Sets the current number of worker processes. Each worker process will serve exactly one client at a time.

#### unicorn

- [`app['appserver']['backlog']`](https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen)
    - **Default:** `1024`

- [`app['appserver']['delay']`](https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen)
    - **Default:** `0.5`

- [`app['appserver']['tcp_nodelay']`](https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen)
    - **Supported values:** `true`, `false`
    - **Default:** `true`

- [`app['appserver']['tcp_nopush']`](https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen)
    - **Supported values:** `true`, `false`
    - **Default:** `false`

- [`app['appserver']['tries']`](https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen)
    - **Default:** `5`

#### puma

- [`app['appserver']['log_requests']`](https://github.com/puma/puma/blob/c169853ff233dd3b5c4e8ed17e84e1a6d8cb565c/examples/config.rb#L56)
    - **Supported values:** `true`, `false`
    - **Default:** `false`

- [`app['appserver']['thread_max']`](https://github.com/puma/puma/blob/c169853ff233dd3b5c4e8ed17e84e1a6d8cb565c/examples/config.rb#L62)
    - **Default:** `16`

- [`app['appserver']['thread_min']`](https://github.com/puma/puma/blob/c169853ff233dd3b5c4e8ed17e84e1a6d8cb565c/examples/config.rb#L62)
    - **Default:** `0`

#### thin

- `app['appserver']['max_connections']`
    - **Default:** `1024`

- `app['appserver']['max_persistent_connections']`
    - **Default:** `512`

- `app['appserver']['timeout']`
    - **Default:** `60`

- `app['appserver']['worker_processes']`
    - **Default:** `4`

### webserver

Webserver configuration. Proxy passing to application is handled out-of-the-box. Currently Apache2 and nginx
is supported.

- `app['webserver']['adapter']`
    - **Default:** `nginx`
    - **Supported values:** `apache2`, `nginx`, `null`
    - Webserver in front of the instance. It runs on port 80, and receives all requests from Load Balancer/Internet. `null` means no webserver enabled.

- `app['webserver']['dhparams']`
    - If you wish to use custom generated DH primes, instead of common ones (which is a very good practice),
      put the contents (not file name) of the `dhparams.pem` file into this attribute.
      [Read more here.](https://weakdh.org/sysadmin.html)

- `app['webserver']['keepalive_timeout']`
    - **Default**: `15`
    - The number of seconds webserver will wait for a subsequent request before closing the connection.

- `app['webserver']['ssl_for_legacy_browsers']`
    - **Supported values:** `true`, `false`
    - **Default:** `false`
    - By default webserver is configured to follow strict SSL security standards,
      [covered in this article](https://cipherli.st/). However, old browsers (like IE < 9 or Android < 2.2) wouldn't
      work with this configuration very well. If your application needs a support for those browsers,
      set this parameter to `true`.

#### apache

- `app['webserver']['extra_config']`
    - Raw Apache2 configuration, which will be inserted into `<Virtualhost *:80>` section of the application.

- `app['webserver']['extra_config_ssl']`
    - Raw Apache2 configuration, which will be inserted into `<Virtualhost *:443>` section of the application.
      If set to `true`, the `extra_config` will be copied.

- [`app['webserver']['limit_request_body']`](https://httpd.apache.org/docs/2.4/mod/core.html#limitrequestbody)
    - **Default**: `1048576`

- [`app['webserver']['log_level']`](https://httpd.apache.org/docs/2.4/mod/core.html#loglevel)
    - **Default**: `info`

- `app['webserver']['log_dir']`
    - **Default**: `/var/log/apache2` (debian) or `/var/log/httpd` (rhel)
    - A place to store application-related Apache2 logs.

- [`app['webserver']['proxy_timeout']`](https://httpd.apache.org/docs/current/mod/mod_proxy.html#proxytimeout)
    - **Default**: `60`

#### nginx

- `app['webserver']['build_type']`
    - **Supported values:** `default` or `source`
    - **Default:** `default`
    - The way the [nginx](https://supermarket.chef.io/cookbooks/nginx) cookbooks handles `nginx` installation.
      Check out [the corresponding docs](https://github.com/miketheman/nginx/tree/2.7.x#recipes) for more details.
      Never use `node['nginx']['install_method']`, as it will be always overwritten by this attribute.

- [`app['webserver']['client_body_timeout']`](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_body_timeout)
    - **Default:** `12`

- [`app['webserver']['client_header_timeout']`](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_header_timeout)
    - **Default:** `12`

- [`app['webserver']['client_max_body_size']`](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size)
    - **Default:** `10m`

- `app['webserver']['extra_config']`
    - Raw nginx configuration, which will be inserted into `server` section of the application for HTTP port.

- `app['webserver']['extra_config_ssl']`
    - Raw nginx configuration, which will be inserted into `server` section of the application for HTTPS port.
      If set to `true`, the `extra_config` will be copied.

- `app['webserver']['log_dir']`
    - **Default**: `/var/log/nginx`
    - A place to store application-related nginx logs.

- [`app['webserver']['proxy_read_timeout']`](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_read_timeout)
    - **Default**: `60`

- [`app['webserver']['proxy_send_timeout']`](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_send_timeout)
    - **Default**: `60`

- [`app['webserver']['send_timeout']`](http://nginx.org/en/docs/http/ngx_http_core_module.html#send_timeout)
    - **Default**: `10`

Since this driver is basically a wrapper for [nginx cookbook](https://github.com/miketheman/nginx/tree/2.7.x),
you can also configure [node['nginx'] attributes](https://github.com/miketheman/nginx/tree/2.7.x#attributes)
as well (notice that `node['deploy'][<application_shortname>]` logic doesn't apply here.)

#### sidekiq

- `app['worker']['config']`
    - Configuration parameters which will be directly passed to the worker. For example, for `sidekiq` they will be
      serialized to [sidekiq.yml config file](https://github.com/mperham/sidekiq/wiki/Advanced-Options#the-sidekiq-configuration-file).

#### delayed_job

- `app['worker']['queues']`
    - Array of queues which should be processed by delayed_job

#### resque

- `app['worker']['workers']`
    - **Default:** `2`
    - Number of resque workers

- `app['worker']['queues']`
    - **Default:** `*`
    - Array of queues which should be processed by resque
