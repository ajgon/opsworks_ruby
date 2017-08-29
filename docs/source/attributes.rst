.. _attributes:

Attributes
==========

| Attributes format follows the guidelines of old Chef 11.x based
  OpsWorks stack.
| So all of them, need to be placed under
  ``node['deploy'][<application_shortname>]``.
| Attributes (and whole logic of this cookbook) are divided to six
  sections.
| Following convention is used:
  ``app == node['deploy'][<application_shortname>]``
| so for example ``app['framework']['adapter']`` actually means
| ``node['deploy'][<application_shortname>]['framework']['adapter']``.

Stack attributes
----------------

These attributes are used on Stack/Layer level globally to configure
the opsworks_ruby cookbook itself. They should'nt be used under
``node['deploy'][<application_shortname>]`` (notice lack of the ``app[]``
convention).

-  ``node['applications']``

  -  An array of application shortnames which should be deployed to given layer.
     If set, only applications witch ``deploy`` flag set (on OpsWorks side) included
     in this list will be deployed. If not set, all ``deploy`` application will be
     supported. This parameter mostly matters during the setup phase, since all
     application in given stack are deployed to the given layer. Using this paramter
     you can narrow the list to application which you actually intend to use.
     **Important** thing is, that when you try to do a manual deploy from OpsWorks
     of an application, not included in this list - it will be skipped, as this list
     takes precedence over anything else.

-  ``node['ruby-ng']['ruby_version']``

  -  **Type:** string
  -  **Default:** ``2.4``
  -  Sets the Ruby version used through the system. See `ruby-ng cookbook documentation`_
     for more details


Application attributes
----------------------

global
~~~~~~

Global parameters apply to the whole application, and can be used by any section
(framework, appserver etc.).

-  ``app['global']['environment']``

  -  **Type:** string
  -  **Default:** ``production``
  -  Sets the “deploy environment” for all the app-related (for example ``RAILS_ENV``
     in Rails) actions in the project (server, worker, etc.)

- ``app['global']['symlinks']``

  -  **Type:** key-value
  -  **Default:** ``{ "system": "public/system", "assets": "public/assets", "cache": "tmp/cache", "pids": "tmp/pids", "log": "log" }``
  -  **Important Notice:** Any values for this parameter will be *merged* to the defaults
  -  List of symlinks created to the ``shared`` directory. The format is ``{"shared_path": "release_path"}``.
     For example ``{"system", "public/system"}`` means: Link ``/src/www/app_name/current/public/system`` to
     ``/src/www/app_name/shared/system``.

- ``app['global']['create_dirs_before_symlink']``

  -  **Type:** array
  -  **Default:** ``["tmp", "public", "config", "../../shared/cache", "../../shared/assets"]``
  -  **Important Notice:** Any values for this parameter will be *appended* to the defaults
  -  List of directories to be created before symlinking. Paths are relative to ``release_path``.
     For example ``tmp`` becomes ``/srv/www/app_name/current/tmp``.

- ``app['global']['purge_before_symlink']``

  -  **Type:** array
  -  **Default:** ``["log", "tmp/cache", "tmp/pids", "public/system", "public/assets"]``
  -  **Important Notice:** Any values for this parameter will be *appended* to the defaults
  -  List of directories to be wiped out before symlinking. Paths are relative to ``release_path``.
     For example ``tmp`` becomes ``/srv/www/app_name/current/tmp``.

- ``app['global']['rollback_on_error']``

  -  **Type:** boolean
  -  **Default:** ``true``
  -  When set to true, any failed deploy will be removed from ``releases`` directory.

- ``app['global']['logrotate_rotate']``

  -  **Type:** integer
  -  **Default:** ``30``
  -  **Important Notice:** The parameter is in days

- ``app['global']['logrotate_script_params']``

  -  **Type:** key-value
  -  **Default:** ``{}``
  -  **Important Notice:** Any values for this parameter will be *merged* to the defaults
  -  List of passable options can be found in the `logrotate man page`_.
     For example ``{"postrotate": "echo 'hi'"}``

database
~~~~~~~~

| Those parameters will be passed without any alteration to the
  ``database.yml``
| file. Keep in mind, that if you have RDS connected to your OpsWorks
  application,
| you don’t need to use them. The chef will do all the job, and
  determine them
| for you.

-  ``app['database']['adapter']``

  -  **Supported values:** ``mariadb``, ``mysql``, ``postgresql``, ``sqlite3``
  -  **Default:** ``sqlite3``
  -  ActiveRecord adapter which will be used for database connection.

-  ``app['database']['username']``

  -  Username used to authenticate to the DB

-  ``app['database']['password']``

  -  Password used to authenticate to the DB

-  ``app['database']['host']``

  -  Database host

-  ``app['database']['database']``

  -  Database name

-  ``app['database'][<any other>]``

  -  Any other key-value pair provided here, will be passed directly to
     the ``database.yml``

scm
~~~

| Those parameters can also be determined from OpsWorks application, and
  usually
| you don’t need to provide them here. Currently only ``git`` is
  supported.

-  ``app['scm']['scm_provider']``

  -  **Supported values:** ``git``
  -  **Default:** ``git``
  -  SCM used by the cookbook to clone the repo.

-  ``app['scm']['remove_scm_files']``

  -  **Supported values:** ``true``, ``false``
  -  **Default:** ``true``
  -  If set to true, all SCM leftovers (like ``.git``) will be removed.

-  ``app['scm']['repository']``

  -  Repository URL

-  ``app['scm']['revision']``

  -  Branch name/SHA1 of commit which should be use as a base of the
     deployment.

-  ``app['scm']['ssh_key']``

  -  A private SSH deploy key (the key itself, not the file name), used
     when fetching repositories via SSH.

-  ``app['scm']['ssh_wrapper']``

  -  A wrapper script, which will be used by git when fetching repository
     via SSH. Essentially, a value of ``GIT_SSH`` environment variable.
     This cookbook provides one of those scripts for you, so you shouldn’t
     alter this variable unless you know what you’re doing.

-  ``app['scm']['enabled_submodules']``

  -  If set to ``true``, any submodules included in the repository, will
     also be fetched.

framework
~~~~~~~~~

| Pre-optimalization for specific frameworks (like migrations, cache etc.).
| Currently ``hanami.rb`` and ``Rails`` are supported.

-  ``app['framework']['adapter']``

  -  **Supported values:** ``null``, ``hanami``, ``padrino``, ``rails``
  -  **Default:** ``rails``
  -  Ruby framework used in project.

-  ``app['framework']['migrate']``

  -  **Supported values:** ``true``, ``false``
  -  **Default:** ``true``
  -  If set to ``true``, migrations will be launch during deployment.

-  ``app['framework']['migration_command']``

  -  A command which will be invoked to perform migration. This cookbook
     comes with predefined migration commands, well suited for the task, and
     usually you don’t have to change this parameter.

-  ``app['framework']['assets_precompile']``

  -  **Supported values:** ``true``, ``false``
  -  **Default:** ``true``

-  ``app['framework']['assets_precompilation_command']``

  -  A command which will be invoked to precompile assets.

padrino
^^^^^^^

| For Padrino, slight adjustments needs to be made. Since there are many database
| adapters supported, instead of creating configuration for each one, the
| ``DATABASE_URL`` environmental variable is provided. You need to parse it in your
| ``config/database.rb`` file and properly pass to the configuration options.
| For example, for ActiveRecord:

.. code:: ruby

    database_url = ENV['DATABASE_URL'] && ActiveRecord::ConnectionAdapters::ConnectionSpecification::ConnectionUrlResolver.new(ENV['DATABASE_URL']).to_hash
    ActiveRecord::Base.configurations[:production] = database_url || {
      :adapter => 'sqlite3',
      :database => Padrino.root('db', 'dummy_app_production.db')
    }

rails
^^^^^

-  ``app['framework']['envs_in_console']``

  -  **Supported values:** ``true``, ``false``
  -  **Default:** ``false``
  -  If set to true, ``rails console`` will be invoked with all
     application-level environment variables set.
  -  **WARNING!** This is highly unstable feature. If you experience any
     troubles with deployments, and have this feature enabled, consider disabling
     it as a first step in your debugging process.

appserver
~~~~~~~~~

| Configuration parameters for the ruby application server. Currently ``Puma``,
| ``Thin`` and ``Unicorn`` are supported.

-  ``app['appserver']['adapter']``

  -  **Default:** ``puma``
  -  **Supported values:** ``puma``, ``thin``, ``unicorn``, ``null``
  -  Server on the application side, which will receive requests from
     webserver in front. ``null`` means no appserver enabled.

-  ``app['appserver']['application_yml']``

  -  **Supported values:** ``true``, ``false``
  -  **Default:** ``false``
  -  Creates a ``config/application.yml`` file with all pre-configured
     environment variables. Useful for gems like `figaro`_

-  ``app['appserver']['dot_env']``

  -  **Supported values:** ``true``, ``false``
  -  **Default:** ``false``
  -  Creates a ``.env`` file with all pre-configured environment
     variables. Useful for gems like `dotenv`_

-  ``app['appserver']['preload_app']``

  -  **Supported values:** ``true``, ``false``
  -  **Default:** ``true``
  -  Enabling this preloads an application before forking worker processes.

-  ``app['appserver']['timeout']``

  -  **Default:** ``50``
  -  Sets the timeout of worker processes to seconds.

-  ``app['appserver']['worker_processes']|``

  -  **Default:** ``4``
  -  Sets the current number of worker processes. Each worker process will
     serve exactly one client at a time.

unicorn
^^^^^^^

-  |app['appserver']['backlog']|_

  -  **Default:** ``1024``

-  |app['appserver']['delay']|_

  -  **Default:** ``0.5``

-  |app['appserver']['tcp_nodelay']|_

  -  **Supported values:** ``true``, ``false``
  -  **Default:** ``true``

-  |app['appserver']['tcp_nopush']|_

  -  **Supported values:** ``true``, ``false``
  -  **Default:** ``false``

-  |app['appserver']['tries']|_

  -  **Default:** ``5``

puma
^^^^

-  |app['appserver']['log_requests']|_

  -  **Supported values:** ``true``, ``false``
  -  **Default:** ``false``

-  |app['appserver']['thread_max']|_

  -  **Default:** ``16``

-  |app['appserver']['thread_min']|_

  -  **Default:** ``0``

thin
^^^^

-  ``app['appserver']['max_connections']``

  -  **Default:** ``1024``

-  ``app['appserver']['max_persistent_connections']``

  -  **Default:** ``512``

-  ``app['appserver']['timeout']``

  -  **Default:** ``60``

-  ``app['appserver']['worker_processes']``

  -  **Default:** ``4``

webserver
~~~~~~~~~

| Webserver configuration. Proxy passing to application is handled out-of-the-box.
| Currently Apache2 and nginx is supported.

-  ``app['webserver']['adapter']``

  -  **Default:** ``nginx``
  -  **Supported values:** ``apache2``, ``nginx``, ``null``
  -  Webserver in front of the instance. It runs on port 80,
     and receives all requests from Load Balancer/Internet.
     ``null`` means no webserver enabled.

-  ``app['webserver']['dhparams']``

  -  If you wish to use custom generated DH primes, instead of common ones
     (which is a very good practice), put the contents (not file name) of
     the ``dhparams.pem`` file into this attribute. `Read more here.`_

-  ``app['webserver']['keepalive_timeout']``

  -  **Default**: ``15``
  -  The number of seconds webserver will wait for a subsequent request
     before closing the connection.

-  ``app['webserver']['ssl_for_legacy_browsers']``

  -  **Supported values:** ``true``, ``false``
  -  **Default:** ``false``
  -  By default webserver is configured to follow strict SSL security standards,
     `covered in this article`_. However, old browsers (like IE < 9 or
     Android < 2.2) wouldn’t work with this configuration very well. If your
     application needs a support for those browsers, set this parameter to ``true``.

apache
^^^^^^

-  ``app['webserver']['extra_config']``

  -  Raw Apache2 configuration, which will be inserted into ``<Virtualhost *:80>``
     section of the application.

-  ``app['webserver']['extra_config_ssl']``

  -  Raw Apache2 configuration, which will be inserted into ``<Virtualhost *:443>``
     section of the application. If set to ``true``, the ``extra_config``
     will be copied.

-  |app['webserver']['limit_request_body']|_

  -  **Default**: ``1048576``

-  |app['webserver']['log_level']|_

  -  **Default**: ``info``

-  ``app['webserver']['log_dir']``

  -  **Default**: ``/var/log/apache2`` (debian) or ``/var/log/httpd`` (rhel)
  -  A place to store application-related Apache2 logs.

-  |app['webserver']['proxy_timeout']|_

  -  **Default**: ``60``

nginx
^^^^^

-  ``app['webserver']['build_type']``

  -  **Supported values:** ``default`` or ``source``
  -  **Default:** ``default``
  -  The way the `chef_nginx`_ cookbook handles ``nginx`` installation.
     Check out `the corresponding docs`_ for more details. Never use
     ``node['nginx']['install_method']``, as it will be always overwritten
     by this attribute.

-  |app['webserver']['client_body_timeout']|_

  -  **Default:** ``12``

-  |app['webserver']['client_header_timeout']|_

  -  **Default:** ``12``

-  |app['webserver']['client_max_body_size']|_

  -  **Default:** ``10m``

-  ``app['webserver']['extra_config']``

  -  Raw nginx configuration, which will be inserted into ``server``
     section of the application for HTTP port.

-  ``app['webserver']['extra_config_ssl']``

  -  Raw nginx configuration, which will be inserted into ``server``
     section of the application for HTTPS port. If set to ``true``,
     the ``extra_config`` will be copied.

-  ``app['webserver']['log_dir']``

  -  **Default**: ``/var/log/nginx``
  -  A place to store application-related nginx logs.

-  |app['webserver']['proxy_read_timeout']|_

  -  **Default**: ``60``

-  |app['webserver']['proxy_send_timeout']|_

  -  **Default**: ``60``

-  |app['webserver']['send_timeout']|_

  -  **Default**: ``10``

-  |app['webserver']['enable_upgrade_method']|_

  -  **Supported values:** ``true``, ``false``
  -  **Default**: ``false``
  -  When set to true, enable Websocket's upgrade method such as Rails actionCable.

| Since this driver is basically a wrapper for `chef_nginx cookbook`_,
| you can also configure `node['nginx'] attributes`_
| as well (notice that ``node['deploy'][<application_shortname>]`` logic
| doesn't apply here.)

worker
~~~~~~

sidekiq
^^^^^^^

-  ``app['worker']['config']``

  -  Configuration parameters which will be directly passed to the worker.
     For example, for ``sidekiq`` they will be serialized to
     `sidekiq.yml config file`_.

delayed\_job
^^^^^^^^^^^^

-  ``app['worker']['queues']``

  -  Array of queues which should be processed by delayed\_job

resque
^^^^^^

-  ``app['worker']['workers']``

  -  **Default:** ``2``
  -  Number of resque workers

-  ``app['worker']['queues']``

  -  **Default:** ``*``
  -  Array of queues which should be processed by resque

.. _ruby-ng cookbook documentation: https://supermarket.chef.io/cookbooks/ruby-ng
.. _logrotate man page: https://linux.die.net/man/8/logrotate
.. _figaro: https://github.com/laserlemon/figaro
.. _dotenv: https://github.com/bkeepers/dotenv
.. |app['appserver']['backlog']| replace:: ``app['appserver']['backlog']``
.. _app['appserver']['backlog']: https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen
.. |app['appserver']['delay']| replace:: ``app['appserver']['delay']``
.. _app['appserver']['delay']: https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen
.. |app['appserver']['tcp_nodelay']| replace:: ``app['appserver']['tcp_nodelay']``
.. _app['appserver']['tcp_nodelay']: https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen
.. |app['appserver']['tcp_nopush']| replace:: ``app['appserver']['tcp_nopush']``
.. _app['appserver']['tcp_nopush']: https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen
.. |app['appserver']['tries']| replace:: ``app['appserver']['tries']``
.. _app['appserver']['tries']: https://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-listen
.. |app['appserver']['log_requests']| replace:: ``app['appserver']['log_requests']``
.. _app['appserver']['log_requests']: https://github.com/puma/puma/blob/c169853ff233dd3b5c4e8ed17e84e1a6d8cb565c/examples/config.rb#L56
.. |app['appserver']['thread_max']| replace:: ``app['appserver']['thread_max']``
.. _app['appserver']['thread_max']: https://github.com/puma/puma/blob/c169853ff233dd3b5c4e8ed17e84e1a6d8cb565c/examples/config.rb#L62
.. |app['appserver']['thread_min']| replace:: ``app['appserver']['thread_min']``
.. _app['appserver']['thread_min']: https://github.com/puma/puma/blob/c169853ff233dd3b5c4e8ed17e84e1a6d8cb565c/examples/config.rb#L62
.. _Read more here.: https://weakdh.org/sysadmin.html
.. _covered in this article: https://cipherli.st/
.. |app['webserver']['limit_request_body']| replace:: ``app['webserver']['limit_request_body']``
.. _app['webserver']['limit_request_body']: https://httpd.apache.org/docs/2.4/mod/core.html#limitrequestbody
.. |app['webserver']['log_level']| replace:: ``app['webserver']['log_level']``
.. _app['webserver']['log_level']: https://httpd.apache.org/docs/2.4/mod/core.html#loglevel
.. |app['webserver']['proxy_timeout']| replace:: ``app['webserver']['proxy_timeout']``
.. _app['webserver']['proxy_timeout']: https://httpd.apache.org/docs/current/mod/mod_proxy.html#proxytimeout
.. _chef_nginx: https://supermarket.chef.io/cookbooks/chef_nginx
.. _the corresponding docs: https://github.com/miketheman/nginx/tree/2.7.x#recipes
.. |app['webserver']['client_body_timeout']| replace:: ``app['webserver']['client_body_timeout']``
.. _app['webserver']['client_body_timeout']: http://nginx.org/en/docs/http/ngx_http_core_module.html#client_body_timeout
.. |app['webserver']['client_header_timeout']| replace:: ``app['webserver']['client_header_timeout']``
.. _app['webserver']['client_header_timeout']: http://nginx.org/en/docs/http/ngx_http_core_module.html#client_header_timeout
.. |app['webserver']['client_max_body_size']| replace:: ``app['webserver']['client_max_body_size']``
.. _app['webserver']['client_max_body_size']: http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size
.. |app['webserver']['proxy_read_timeout']| replace:: ``app['webserver']['proxy_read_timeout']``
.. _app['webserver']['proxy_read_timeout']: http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_read_timeout
.. |app['webserver']['proxy_send_timeout']| replace:: ``app['webserver']['proxy_send_timeout']``
.. _app['webserver']['proxy_send_timeout']: http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_send_timeout
.. |app['webserver']['send_timeout']| replace:: ``app['webserver']['send_timeout']``
.. _app['webserver']['send_timeout']: http://nginx.org/en/docs/http/ngx_http_core_module.html#send_timeout
.. _chef_nginx cookbook: https://github.com/chef-cookbooks/chef_nginx
.. |node['nginx'] attributes| replace:: ``node['nginx']`` attributes
.. _node['nginx'] attributes: https://github.com/miketheman/nginx/tree/2.7.x#attributes
.. |sidekiq.yml config file| replace:: ``sidekiq.yml`` config file
.. _sidekiq.yml config file: https://github.com/mperham/sidekiq/wiki/Advanced-Options#the-sidekiq-configuration-file

