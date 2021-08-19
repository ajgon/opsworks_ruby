# Changelog

## [1.1.1](https://github.com/ajgon/opsworks_ruby/compare/v1.1.0...v1.1.1) (2016-10-21)


### Bug Fixes

* **deploy:** Fixed deploy callbacks launching order ([81d31c9](https://github.com/ajgon/opsworks_ruby/commit/81d31c9))




## [1.1.0](https://github.com/ajgon/opsworks_ruby/compare/v1.0.0...v1.1.0) (2016-10-21)


### Bug Fixes

* Application deployment fix ([7ac4166](https://github.com/ajgon/opsworks_ruby/commit/7ac4166))


### BREAKING CHANGES

* `node['applications']` becomes obsolete




## [1.0.0](https://github.com/ajgon/opsworks_ruby/compare/v0.8.0...v1.0.0) (2016-10-04)


### Bug Fixes

* `monit reload` and `monit restart` order ([2c4a84a](https://github.com/ajgon/opsworks_ruby/commit/2c4a84a)), closes [#29](https://github.com/ajgon/opsworks_ruby/issues/29)
* **appserver:** Removed `accept_filter` from unicorn configurator ([76a7f36](https://github.com/ajgon/opsworks_ruby/commit/76a7f36))
* **framework:** Added missing `deploy_environment` to `null` framework ([673a21d](https://github.com/ajgon/opsworks_ruby/commit/673a21d))
* **framework:** Fixed `envs_in_console` for `rails` ([f8856c8](https://github.com/ajgon/opsworks_ruby/commit/f8856c8))


### Features

* **appserver:** "Puma" support added ([f6e80ad](https://github.com/ajgon/opsworks_ruby/commit/f6e80ad)), closes [#38](https://github.com/ajgon/opsworks_ruby/issues/38)
* **appserver:** "Thin" support added ([9667939](https://github.com/ajgon/opsworks_ruby/commit/9667939)), closes [#39](https://github.com/ajgon/opsworks_ruby/issues/39)
* **appserver:** Switched default appserver from `unicorn` to `puma` ([0e72200](https://github.com/ajgon/opsworks_ruby/commit/0e72200))
* **framework:** "hanami.rb" support added ([23fdd04](https://github.com/ajgon/opsworks_ruby/commit/23fdd04)), closes [#43](https://github.com/ajgon/opsworks_ruby/issues/43)
* **framework:** "Null" support added ([b9e7b63](https://github.com/ajgon/opsworks_ruby/commit/b9e7b63)), closes [#47](https://github.com/ajgon/opsworks_ruby/issues/47)
* **framework:** "Padrino" support added ([a240d92](https://github.com/ajgon/opsworks_ruby/commit/a240d92)), closes [#44](https://github.com/ajgon/opsworks_ruby/issues/44)
* **framework:** Environemnt variables in `rails console` ([89252b3](https://github.com/ajgon/opsworks_ruby/commit/89252b3))
* **global:** Moved `app['environment']` to `app['global']['environment']` ([432a21c](https://github.com/ajgon/opsworks_ruby/commit/432a21c)), closes [#50](https://github.com/ajgon/opsworks_ruby/issues/50)
* **webserver:** "Apache2" support added ([1ca5b0b](https://github.com/ajgon/opsworks_ruby/commit/1ca5b0b)), closes [#40](https://github.com/ajgon/opsworks_ruby/issues/40)
* **worker:** "delayed_job" support added ([7235720](https://github.com/ajgon/opsworks_ruby/commit/7235720)), closes [#42](https://github.com/ajgon/opsworks_ruby/issues/42)
* **worker:** "resque" support added ([ccc13e4](https://github.com/ajgon/opsworks_ruby/commit/ccc13e4)), closes [#41](https://github.com/ajgon/opsworks_ruby/issues/41)


### Performance Improvements

* Added `fasterer` gem to overcommit ([c1ed974](https://github.com/ajgon/opsworks_ruby/commit/c1ed974))


### BREAKING CHANGES

* global: If you were using an `app['environment']` variable (for example to set env to
staging), please update your stack/layer JSONs to `app['global']['environment']`.
* appserver: Unicorn is no longer a default appserver, in favor of Puma. If you have a working
instances which were relying on that, you have to either set `app['appserver']['adapter'] =
'unicorn'` in your stack/layer JSON file, or switch the app server in your application
* webserver: `sites-available` and `sites-enabled` file names format
changed. From this commit, the `*.conf` extension is appended. If you
plan to update your cookbooks on productional environments, don't forget
to remove the old ones, otherwise you will end up with two the same
configurations in different files, which cause `nginx` to fail.

If you start noticing `duplicate upstream` errors, this is probably due
this case.



## [0.8.0](https://github.com/ajgon/opsworks_ruby/compare/v0.7.0...v0.8.0) (2016-09-02)


### Bug Fixes

* Switched from `nginx reload` to `nginx restart` after succesful deploy/undeploy ([16ab9d1](https://github.com/ajgon/opsworks_ruby/commit/16ab9d1)), closes [#36](https://github.com/ajgon/opsworks_ruby/issues/36)


### Features

* Added GIT_SSH support for bundle install ([232e8ac](https://github.com/ajgon/opsworks_ruby/commit/232e8ac)), closes [#37](https://github.com/ajgon/opsworks_ruby/issues/37)
* Caches bundler installs to speed up deployments ([baa0f44](https://github.com/ajgon/opsworks_ruby/commit/baa0f44))
* Implemented configurable RAILS_ENV ([2567b71](https://github.com/ajgon/opsworks_ruby/commit/2567b71)), closes [#34](https://github.com/ajgon/opsworks_ruby/issues/34)



## [0.7.0](https://github.com/ajgon/opsworks_ruby/compare/v0.4.0...v0.7.0) (2016-08-29)


### Bug Fixes

* Moved extra env files creation, later in the stack (before_restart) ([8a5223f](https://github.com/ajgon/opsworks_ruby/commit/8a5223f))
* Reload monit after restarting services ([eaa2aab](https://github.com/ajgon/opsworks_ruby/commit/eaa2aab))
* Set the default DB adapter to `sqlite3` ([b4b1ee4](https://github.com/ajgon/opsworks_ruby/commit/b4b1ee4))
* specify bundle path on bundle install ([b9d4335](https://github.com/ajgon/opsworks_ruby/commit/b9d4335))


### Features

* Added support for gems like figaro and dotenv ([c989494](https://github.com/ajgon/opsworks_ruby/commit/c989494)), closes [#28](https://github.com/ajgon/opsworks_ruby/issues/28)



## [0.6.0](https://github.com/ajgon/opsworks_ruby/compare/v0.5.0...v0.6.0) (2016-08-17)

### BREAKING CHANGES

* Removed `application_ruby` cookbook dependency



## [0.5.0](https://github.com/ajgon/opsworks_ruby/compare/v0.4.0...v0.5.0) (2016-07-21)


### Features

* Added configuration for isolated worker servers w/o app/webserver ([56642f1](https://github.com/ajgon/opsworks_ruby/commit/56642f1))
* Added monit compatibility with amazon linux ([2ef12b9](https://github.com/ajgon/opsworks_ruby/commit/2ef12b9))



## [0.4.0](https://github.com/ajgon/opsworks_ruby/compare/v0.3.1...v0.4.0) (2016-06-16)


### Features

* Enables drivers to be attached to before_* and after_* deploy events ([fa8e605](https://github.com/ajgon/opsworks_ruby/commit/fa8e605))



## [0.3.1](https://github.com/ajgon/opsworks_ruby/compare/v0.3.0...v0.3.1) (2016-06-16)


### Bug Fixes

* Change path to 500.html to be in the "current" dir ([4aeac7f](https://github.com/ajgon/opsworks_ruby/commit/4aeac7f))
* Support for multiple RDSes with multiple applications ([a23df47](https://github.com/ajgon/opsworks_ruby/commit/a23df47))



## [0.3.0](https://github.com/ajgon/opsworks_ruby/compare/v0.2.1...v0.3.0) (2016-06-08)


### Features

* eliminate RDS requirement ([daa4254](https://github.com/ajgon/opsworks_ruby/commit/daa4254))


### BREAKING CHANGES

* Sqlite3 is no longer set as the default database
adapter.

In order to use sqlite as the database adapter it must be defined
in the node.



## 0.2.1 (2016-05-11)

* Added environment variables support for assets precompile ([f24e742](https://github.com/ajgon/opsworks_ruby/commit/f24e742))
* Added optional removal of scm files ([82b25ec](https://github.com/ajgon/opsworks_ruby/commit/82b25ec))
* Added support for custom configuration in nginx ([448019a](https://github.com/ajgon/opsworks_ruby/commit/448019a))
* Fixed deploy environment ([bf843aa](https://github.com/ajgon/opsworks_ruby/commit/bf843aa))
* Fixed nginx defaults order ([af560db](https://github.com/ajgon/opsworks_ruby/commit/af560db))
* Fixed sidekiq config builder ([a32b410](https://github.com/ajgon/opsworks_ruby/commit/a32b410))



## 0.2.0 (2016-04-24)

* Added MariaDB Driver support ([197b7de](https://github.com/ajgon/opsworks_ruby/commit/197b7de))
* Added multi-platform support ([6118154](https://github.com/ajgon/opsworks_ruby/commit/6118154))
* Added MySQL Driver support ([72d4b9f](https://github.com/ajgon/opsworks_ruby/commit/72d4b9f))
* Added Sqlite Driver support ([3ecb321](https://github.com/ajgon/opsworks_ruby/commit/3ecb321))
* Minor bugfixes, resolves #19 ([9f8615f](https://github.com/ajgon/opsworks_ruby/commit/9f8615f)), closes [#19](https://github.com/ajgon/opsworks_ruby/issues/19)



## 0.1.0 (2016-04-23)

* `configure` recipe initial implementation ([c57f71e](https://github.com/ajgon/opsworks_ruby/commit/c57f71e))
* Added assets precompilation support. Resolves #12 ([b8d8ff5](https://github.com/ajgon/opsworks_ruby/commit/b8d8ff5)), closes [#12](https://github.com/ajgon/opsworks_ruby/issues/12)
* Added auto-start of nginx to setup phase. Resolves #15 ([fbb07dc](https://github.com/ajgon/opsworks_ruby/commit/fbb07dc)), closes [#15](https://github.com/ajgon/opsworks_ruby/issues/15)
* Added basic documentation ([235519f](https://github.com/ajgon/opsworks_ruby/commit/235519f))
* Added code quality tools ([730857f](https://github.com/ajgon/opsworks_ruby/commit/730857f))
* Added core_ext specs. Resolves #7 ([b089eb3](https://github.com/ajgon/opsworks_ruby/commit/b089eb3)), closes [#7](https://github.com/ajgon/opsworks_ruby/issues/7)
* Added DHparams and nginx version detection support. Resolves #8 and resolves #9 ([4e60594](https://github.com/ajgon/opsworks_ruby/commit/4e60594)), closes [#8](https://github.com/ajgon/opsworks_ruby/issues/8) [#9](https://github.com/ajgon/opsworks_ruby/issues/9)
* Added missing specs ([ff85e4f](https://github.com/ajgon/opsworks_ruby/commit/ff85e4f))
* Added nginx reload after deploy. Resolves #13 ([f1bc277](https://github.com/ajgon/opsworks_ruby/commit/f1bc277)), closes [#13](https://github.com/ajgon/opsworks_ruby/issues/13)
* Added ruby and bundler installation to setup phase ([0182e70](https://github.com/ajgon/opsworks_ruby/commit/0182e70)), closes [#5](https://github.com/ajgon/opsworks_ruby/issues/5) [#6](https://github.com/ajgon/opsworks_ruby/issues/6)
* Added symlinking defaults. Resolves #16 ([4a1edd9](https://github.com/ajgon/opsworks_ruby/commit/4a1edd9)), closes [#16](https://github.com/ajgon/opsworks_ruby/issues/16)
* Added travis config and coveralls support ([a782a64](https://github.com/ajgon/opsworks_ruby/commit/a782a64))
* Added undeploy recipe ([aba311b](https://github.com/ajgon/opsworks_ruby/commit/aba311b))
* Added webserver setup (nginx) ([1581def](https://github.com/ajgon/opsworks_ruby/commit/1581def))
* Added workers support. Resolves #18 ([05e3a75](https://github.com/ajgon/opsworks_ruby/commit/05e3a75)), closes [#18](https://github.com/ajgon/opsworks_ruby/issues/18)
* Appserver implemented (unicorn) ([bbb79cc](https://github.com/ajgon/opsworks_ruby/commit/bbb79cc))
* Basic SCM support implemented ([bcab3d7](https://github.com/ajgon/opsworks_ruby/commit/bcab3d7))
* Finished database support in recipes ([cf955a0](https://github.com/ajgon/opsworks_ruby/commit/cf955a0))
* Fixed appserver restart sequence ([9a75f9c](https://github.com/ajgon/opsworks_ruby/commit/9a75f9c))
* Fixed nginx defaults. Resolves #14 and resolves #17 ([8320f3b](https://github.com/ajgon/opsworks_ruby/commit/8320f3b)), closes [#14](https://github.com/ajgon/opsworks_ruby/issues/14) [#17](https://github.com/ajgon/opsworks_ruby/issues/17)
* Fixes on bugs detected while deploying to real OpsWorks ([035363b](https://github.com/ajgon/opsworks_ruby/commit/035363b))
* Initial commit ([d8bed5c](https://github.com/ajgon/opsworks_ruby/commit/d8bed5c))
* Initial version, with simple postgresql driver introduced ([5d00083](https://github.com/ajgon/opsworks_ruby/commit/5d00083))
* Moved DB packages installation from configure to setup ([e23f2d4](https://github.com/ajgon/opsworks_ruby/commit/e23f2d4))
* Moved libraries to flat directory structure, because AWS chef hates us ([e6aa211](https://github.com/ajgon/opsworks_ruby/commit/e6aa211))
* Rails deploy hooks implemented ([79d2d64](https://github.com/ajgon/opsworks_ruby/commit/79d2d64))
* Recipes cleanup: added missing actions and shutdown recipe ([9eb9bb8](https://github.com/ajgon/opsworks_ruby/commit/9eb9bb8))
* Reorganized appserver cookbooks, added bundle install to deploy ([2e9947b](https://github.com/ajgon/opsworks_ruby/commit/2e9947b))




