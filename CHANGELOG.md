<a name="0.3.1"></a>
## [0.3.1](https://github.com/ajgon/opsworks_ruby/compare/v0.3.0...v0.3.1) (2016-06-16)


### Bug Fixes

* Change path to 500.html to be in the "current" dir ([4aeac7f](https://github.com/ajgon/opsworks_ruby/commit/4aeac7f))
* Support for multiple RDSes with multiple applications ([a23df47](https://github.com/ajgon/opsworks_ruby/commit/a23df47))



<a name="0.3.0"></a>
# [0.3.0](https://github.com/ajgon/opsworks_ruby/compare/v0.2.1...v0.3.0) (2016-06-08)


### Features

* eliminate RDS requirement ([daa4254](https://github.com/ajgon/opsworks_ruby/commit/daa4254))


### BREAKING CHANGES

* Sqlite3 is no longer set as the default database
adapter.

In order to use sqlite as the database adapter it must be defined
in the node.



<a name="0.2.1"></a>
## 0.2.1 (2016-05-11)

* Added environment variables support for assets precompile ([f24e742](https://github.com/ajgon/opsworks_ruby/commit/f24e742))
* Added optional removal of scm files ([82b25ec](https://github.com/ajgon/opsworks_ruby/commit/82b25ec))
* Added support for custom configuration in nginx ([448019a](https://github.com/ajgon/opsworks_ruby/commit/448019a))
* Fixed deploy environment ([bf843aa](https://github.com/ajgon/opsworks_ruby/commit/bf843aa))
* Fixed nginx defaults order ([af560db](https://github.com/ajgon/opsworks_ruby/commit/af560db))
* Fixed sidekiq config builder ([a32b410](https://github.com/ajgon/opsworks_ruby/commit/a32b410))



<a name="0.2.0"></a>
# 0.2.0 (2016-04-24)

* Added MariaDB Driver support ([197b7de](https://github.com/ajgon/opsworks_ruby/commit/197b7de))
* Added multi-platform support ([6118154](https://github.com/ajgon/opsworks_ruby/commit/6118154))
* Added MySQL Driver support ([72d4b9f](https://github.com/ajgon/opsworks_ruby/commit/72d4b9f))
* Added Sqlite Driver support ([3ecb321](https://github.com/ajgon/opsworks_ruby/commit/3ecb321))
* Minor bugfixes, resolves #19 ([9f8615f](https://github.com/ajgon/opsworks_ruby/commit/9f8615f)), closes [#19](https://github.com/ajgon/opsworks_ruby/issues/19)



<a name="0.1.0"></a>
# 0.1.0 (2016-04-23)

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



