# Changelog

# [1.21.0](https://github.com/ajgon/opsworks_ruby/compare/v1.20.3...v1.21.0) (2021-10-08)


### Bug Fixes

* patch broken SSL certificates list ([4887cf5](https://github.com/ajgon/opsworks_ruby/commit/4887cf5dcb87dd417e3c6657f41bdb5166b113ef)), closes [#268](https://github.com/ajgon/opsworks_ruby/issues/268)
* update rubies for ruby-nq and fullstack, set default ruby to 2.7 ([09ba7e1](https://github.com/ajgon/opsworks_ruby/commit/09ba7e190e78cf79a7e42fde3cb0cc86d11aa836)), closes [#266](https://github.com/ajgon/opsworks_ruby/issues/266)


### BREAKING CHANGES

* By default new list of SSL certificates is used.

It should not affect any of your current deployments, but if you start
seeing SSL errors, the first thing you should check, is disabling
`node['patches']['chef12_ssl_fix']` option.

See https://github.com/ajgon/opsworks_ruby/issues/268 for more
information.



## [1.20.3](https://github.com/ajgon/opsworks_ruby/compare/v1.20.2...v1.20.3) (2021-05-06)


### Features

* **webserver:** apache2 - configurable `mod_status` ([a82335d](https://github.com/ajgon/opsworks_ruby/commit/a82335d4ef90782dfdbf4fba97690f73d18cc62a)), closes [#259](https://github.com/ajgon/opsworks_ruby/issues/259)



## [1.20.2](https://github.com/ajgon/opsworks_ruby/compare/v1.20.1...v1.20.2) (2021-02-07)


### Bug Fixes

* run `monit reload` only once, after `configure hook` ([1b784d1](https://github.com/ajgon/opsworks_ruby/commit/1b784d15c7003490ef4691cab29e4a49dec91cd0)), closes [#251](https://github.com/ajgon/opsworks_ruby/issues/251)




## [1.20.1](https://github.com/ajgon/opsworks_ruby/compare/v1.20.0...v1.20.1) (2020-12-12)


### Features

* **webserver:** add CORS for /packs endpoints ([ede019d](https://github.com/ajgon/opsworks_ruby/commit/ede019dce9472f7bdf5f4c6f0fdd0c0e8df59f37)), closes [#248](https://github.com/ajgon/opsworks_ruby/issues/248)




## [1.20.0](https://github.com/ajgon/opsworks_ruby/compare/v1.19.0...v1.20.0) (2020-12-08)


### Bug Fixes

* **setup:** fix fullstaq key url ([#247](https://github.com/ajgon/opsworks_ruby/issues/247)) ([62ced10](https://github.com/ajgon/opsworks_ruby/commit/62ced108e339c9932a7ace310ee0b2b5303d497c))


### Features

* **appserver:** move appserver processes to foreground ([37b9465](https://github.com/ajgon/opsworks_ruby/commit/37b9465733c5c3b201fd9ce8df75695848c4c0bf)), closes [#244](https://github.com/ajgon/opsworks_ruby/issues/244)
* **deploy:** use revision-based deploy provider ([#245](https://github.com/ajgon/opsworks_ruby/issues/245)) ([27887e6](https://github.com/ajgon/opsworks_ruby/commit/27887e6b50d94be77b28ee40166019b3f5b92b44))


### BREAKING CHANGES

* **appserver:** Theoretically everything should work out of the box,
and you shouldn't notice any change on your environment. However if your
appserver start behave oddly (or probably - won't start at all) - this
may be the first reason for that. Check generated monit files, check if
monit is running and also check the syslog (monit is configured to write
all the appserver output there).




## [1.19.0](https://github.com/ajgon/opsworks_ruby/compare/v1.18.1...v1.19.0) (2020-08-02)


### Features

* **deploy:** include deploy resource polyfill ([4f6d6fd](https://github.com/ajgon/opsworks_ruby/commit/4f6d6fd634e949ee7751664d7da5061a1d2ea748)), closes [#242](https://github.com/ajgon/opsworks_ruby/issues/242)




## [1.18.1](https://github.com/ajgon/opsworks_ruby/compare/v1.18.0...v1.18.1) (2020-05-13)


### Bug Fixes

* **setup:** link fullstaq ruby to /usr/local/bin ([559c015](https://github.com/ajgon/opsworks_ruby/commit/559c0158b80182326c371ed366259ef4ef7d0913)), closes [#237](https://github.com/ajgon/opsworks_ruby/issues/237)



## [1.18.0](https://github.com/ajgon/opsworks_ruby/compare/v1.17.0...v1.18.0) (2020-02-29)


### Bug Fixes

* **appserver:** fix .env and application.yml symlinks creation ([0580955](https://github.com/ajgon/opsworks_ruby/commit/05809558c5aa1eb10dd4e883f2e2dcfd7654b712)), closes [#232](https://github.com/ajgon/opsworks_ruby/issues/232)


### Features

* **appserver:** Add new appserver config params for passenger ([#227](https://github.com/ajgon/opsworks_ruby/issues/227)) ([0500521](https://github.com/ajgon/opsworks_ruby/commit/050052148c543c557783589cf0347fd026f16bfd))
* **setup:** add support for fullstaq ruby repos ([1489d01](https://github.com/ajgon/opsworks_ruby/commit/1489d01c14caf51d2150784db09cfdecfddf281a)), closes [#229](https://github.com/ajgon/opsworks_ruby/issues/229)




## [1.17.0](https://github.com/ajgon/opsworks_ruby/compare/v1.16.0...v1.17.0) (2019-11-23)


### Bug Fixes

* replace symlink options instead of appending them ([b2650fb](https://github.com/ajgon/opsworks_ruby/commit/b2650fbea79c44d4f073c00a511a1017b3d4199f)), closes [#224](https://github.com/ajgon/opsworks_ruby/issues/224)


### Features

* **database:** add support for multiple databases per environment ([0c7f89f](https://github.com/ajgon/opsworks_ruby/commit/0c7f89fe83933be7ef0cead39363dce7e8fbe346)), closes [#226](https://github.com/ajgon/opsworks_ruby/issues/226)


### BREAKING CHANGES

* `app['global']['create_dirs_before_symlink']`,
`app['global']['purge_before_symlink']` and `app['global']['symlinks']`
now overrides defaults instead of appending them. If you were relying on
those options in your Custom JSON, you need to add missing defaults
manually.

For example given:

```json
{
  "deploy": {
    "myapp": {
      "global": {
        "create_dirs_before_symlink": ["test/create"],
        "purge_before_symlink": ["test/purge"],
        "symlinks": {
          "test": "test/symlinks"
        }
      }
    }
  }
}
```

you need to replace it to:

```json
{
  "deploy": {
    "myapp": {
      "global": {
        "create_dirs_before_symlink": ["tmp", "public", "config", "../../shared/cache", "../../shared/assets", "test/create"],
        "purge_before_symlink": ["log", "tmp/cache", "tmp/pids", "public/system", "public/assets", "test/purge"],
        "symlinks": {
          "system": "public/system",
          "assets": "public/assets",
          "cache": "tmp/cache",
          "pids": "tmp/pids",
          "log": "log",
          "test": "test/symlinks"
        }
      }
    }
  }
}
```




## [1.16.0](https://github.com/ajgon/opsworks_ruby/compare/v1.15.0...v1.16.0) (2019-09-11)


### Bug Fixes

* **webserver:** remove default nginx config from conf.d ([#220](https://github.com/ajgon/opsworks_ruby/issues/220)) ([23929e3](https://github.com/ajgon/opsworks_ruby/commit/23929e3))
* keep the last `nginx` cookbook version compatible with chef 12 ([b5b13d0](https://github.com/ajgon/opsworks_ruby/commit/b5b13d0)), closes [#222](https://github.com/ajgon/opsworks_ruby/issues/222)


### Features

* **setup:** add chef version configuration option ([ffe2b42](https://github.com/ajgon/opsworks_ruby/commit/ffe2b42))




## [1.15.0](https://github.com/ajgon/opsworks_ruby/compare/v1.14.0...v1.15.0) (2019-07-09)


### Bug Fixes

* **apache:** fix apache serving assets rather than proxying to app server ([#210](https://github.com/ajgon/opsworks_ruby/issues/210)) ([9dfdeed](https://github.com/ajgon/opsworks_ruby/commit/9dfdeed))
* **appserver:** Compare lockfiles instead of main Gemfile ([c02af02](https://github.com/ajgon/opsworks_ruby/commit/c02af02))
* **appserver:** fix duplicate after_fork/on_worker_boot stanzas in appserver configs ([c0b0e84](https://github.com/ajgon/opsworks_ruby/commit/c0b0e84))
* **worker:** adapted monit config for sidekiq 6.x ([4a58654](https://github.com/ajgon/opsworks_ruby/commit/4a58654)), closes [#215](https://github.com/ajgon/opsworks_ruby/issues/215)
* **worker:** fix sidekiq quiet/shutdown scripts ([59198b9](https://github.com/ajgon/opsworks_ruby/commit/59198b9)), closes [#217](https://github.com/ajgon/opsworks_ruby/issues/217)
* **worker:** quieting and stopping sidekiq ([efc1231](https://github.com/ajgon/opsworks_ruby/commit/efc1231))


### Features

* **apache:** apache configuration to use appserver’s port provided in custom json ([b576788](https://github.com/ajgon/opsworks_ruby/commit/b576788))
* **setup:** add global option for enabling/disabling nodejs ([1f1fa4b](https://github.com/ajgon/opsworks_ruby/commit/1f1fa4b))
* **setup:** support for webpacker ([569b9bb](https://github.com/ajgon/opsworks_ruby/commit/569b9bb))
* **setup:** use latest nodejs lts 10.15.3 ([61bb605](https://github.com/ajgon/opsworks_ruby/commit/61bb605))




## [1.14.0](https://github.com/ajgon/opsworks_ruby/compare/v1.13.0...v1.14.0) (2019-03-06)


### Bug Fixes

* Ensure shared/system dir is created ([#197](https://github.com/ajgon/opsworks_ruby/issues/197)) ([7f8cb2e](https://github.com/ajgon/opsworks_ruby/commit/7f8cb2e)), closes [/github.com/ajgon/opsworks_ruby/blob/6e2328941996d98316657d7a52c98de6982068a5/attributes/default.rb#L21](https://github.com//github.com/ajgon/opsworks_ruby/blob/6e2328941996d98316657d7a52c98de6982068a5/attributes/default.rb/issues/L21)
* Lock the windows cookbook dependency to maintain chef 12 compatibility ([#196](https://github.com/ajgon/opsworks_ruby/issues/196)) ([a2d4a8d](https://github.com/ajgon/opsworks_ruby/commit/a2d4a8d))
* register gpg public key for nginx on ubuntu18.04LTS ([#201](https://github.com/ajgon/opsworks_ruby/issues/201)) ([1d4705d](https://github.com/ajgon/opsworks_ruby/commit/1d4705d))
* **apache:** fix infinite redirect loop on apache, when rails `force_ssl` is enabled ([3df3a16](https://github.com/ajgon/opsworks_ruby/commit/3df3a16)), closes [#206](https://github.com/ajgon/opsworks_ruby/issues/206)
* **appserver:** fixed Puma config compatibility with older versions of Puma ([eebdc23](https://github.com/ajgon/opsworks_ruby/commit/eebdc23)), closes [#207](https://github.com/ajgon/opsworks_ruby/issues/207)
* **nginx:** add missing `nosniff` header for SSL sessions in nginx ([e61b199](https://github.com/ajgon/opsworks_ruby/commit/e61b199))
* **setup:** added support for bundler 2.x and rubygems 3.x ([7b781bd](https://github.com/ajgon/opsworks_ruby/commit/7b781bd)), closes [#203](https://github.com/ajgon/opsworks_ruby/issues/203)
* **webserver:** Align SSL directory between template & driver ([414298e](https://github.com/ajgon/opsworks_ruby/commit/414298e)), closes [#205](https://github.com/ajgon/opsworks_ruby/issues/205)


### Features

* **appserver:** re-establish database connections when preloading app ([db17de6](https://github.com/ajgon/opsworks_ruby/commit/db17de6)), closes [#198](https://github.com/ajgon/opsworks_ruby/issues/198)
* **ruby:** Added support for ruby 2.6 ([27bad91](https://github.com/ajgon/opsworks_ruby/commit/27bad91))




## [1.13.0](https://github.com/ajgon/opsworks_ruby/compare/v1.12.0...v1.13.0) (2018-11-09)


### Bug Fixes

* **db:** Fix typo for aurora postgresql ([1bb2fb5](https://github.com/ajgon/opsworks_ruby/commit/1bb2fb5))


### Features

* **worker:** Support Shoryuken worker library ([5359679](https://github.com/ajgon/opsworks_ruby/commit/5359679))




## [1.12.0](https://github.com/ajgon/opsworks_ruby/compare/v1.11.0...v1.12.0) (2018-10-03)


### Features

* **appserver:** add port configuration ([6540201](https://github.com/ajgon/opsworks_ruby/commit/6540201))
* **database:** added aurora-postgres as an accepted engine for Postgres RDS ([626a11d](https://github.com/ajgon/opsworks_ruby/commit/626a11d))
* **webserver:** add support for `force_ssl` attribute ([2281047](https://github.com/ajgon/opsworks_ruby/commit/2281047)), closes [#189](https://github.com/ajgon/opsworks_ruby/issues/189)




## [1.11.0](https://github.com/ajgon/opsworks_ruby/compare/v1.10.1...v1.11.0) (2018-07-17)


### Bug Fixes

* add Apache 2.4's "Require all granted" to apache2+passenger config file ([#171](https://github.com/ajgon/opsworks_ruby/issues/171)) ([f4e5871](https://github.com/ajgon/opsworks_ruby/commit/f4e5871))
* **webserver:** add `X-Content-Type-Options: nosniff` to assets served by rails for extra security ([07d3336](https://github.com/ajgon/opsworks_ruby/commit/07d3336))


### Features

* **webserver:** hardened security headers, disabled tls1.0 and tls1.1 for non-legacy SSL config ([8351d58](https://github.com/ajgon/opsworks_ruby/commit/8351d58))


### BREAKING CHANGES

* **webserver:** If you are using SSL in your project, TLSv1.0 and
TLSv1.1 has been disabled for all responses - only TLSv1.2 is served. If
you still need older ciphers, consider using
`app['webserver']['ssl_for_legacy_browsers']` configuration option.




## [1.10.1](https://github.com/ajgon/opsworks_ruby/compare/v1.10.0...v1.10.1) (2018-06-24)


### Bug Fixes

* do not read pidfile at each stop retry (prevent from early pidfile deletion) ([c5f0fe4](https://github.com/ajgon/opsworks_ruby/commit/c5f0fe4)), closes [#163](https://github.com/ajgon/opsworks_ruby/issues/163)
* **framework:** added environment variables context to bundle install ([fe01d45](https://github.com/ajgon/opsworks_ruby/commit/fe01d45)), closes [#167](https://github.com/ajgon/opsworks_ruby/issues/167)


### Features

* **appserver:** support rails restart command on puma. ([bb04fb4](https://github.com/ajgon/opsworks_ruby/commit/bb04fb4))
* **db:** added postgis driver ([6b3c058](https://github.com/ajgon/opsworks_ruby/commit/6b3c058)), closes [#165](https://github.com/ajgon/opsworks_ruby/issues/165)




## [1.10.0](https://github.com/ajgon/opsworks_ruby/compare/v1.9.1...v1.10.0) (2018-06-10)


### Bug Fixes

* **appserver:** moved env files creation to `before_symlink` phase ([2ed059d](https://github.com/ajgon/opsworks_ruby/commit/2ed059d)), closes [#157](https://github.com/ajgon/opsworks_ruby/issues/157)
* **setup:** Fixed `deployer` user setup ([9af3651](https://github.com/ajgon/opsworks_ruby/commit/9af3651)), closes [#159](https://github.com/ajgon/opsworks_ruby/issues/159)


### Features

* **appserver:** add additional puma configuration options ([f994e2f](https://github.com/ajgon/opsworks_ruby/commit/f994e2f))
* **ruby:** introduced new `ruby-version` JSON parameter. ([99798ce](https://github.com/ajgon/opsworks_ruby/commit/99798ce)), closes [#156](https://github.com/ajgon/opsworks_ruby/issues/156)


### BREAKING CHANGES

* **ruby:** If you were using `ruby-ng.ruby_version` JSON
configuration parameter in your stack/layer configuration, please change
it to `ruby-version`. Since `ruby-version` is set by default to the
freshest version of ruby available, you may end up with unexpected
upgrade of ruby on your system.




## [1.9.1](https://github.com/ajgon/opsworks_ruby/compare/v1.9.0...v1.9.1) (2018-05-22)


### Bug Fixes

* **chef:** Downgraded apt cookbook below version 7 ([8ea8eee](https://github.com/ajgon/opsworks_ruby/commit/8ea8eee)), closes [#151](https://github.com/ajgon/opsworks_ruby/issues/151)
* **chef:** Removed broken `deployer` cookbook ([51a4942](https://github.com/ajgon/opsworks_ruby/commit/51a4942)), closes [#155](https://github.com/ajgon/opsworks_ruby/issues/155)




## [1.9.0](https://github.com/ajgon/opsworks_ruby/compare/v1.8.0...v1.9.0) (2018-03-17)


### Bug Fixes

* **appserver:** Wait up to 10 sec for graceful shutdown ([def1c21](https://github.com/ajgon/opsworks_ruby/commit/def1c21)), closes [#127](https://github.com/ajgon/opsworks_ruby/issues/127)
* **configure:** Don't create pids symlink if it already exists ([4671ac9](https://github.com/ajgon/opsworks_ruby/commit/4671ac9)), closes [#126](https://github.com/ajgon/opsworks_ruby/issues/126)
* **appserver:** failed to start appserver. ([#146](https://github.com/ajgon/opsworks_ruby/issues/146)) ([4505890](https://github.com/ajgon/opsworks_ruby/commit/4505890))
* **source:** remove temporary directories after deploy ([b92417f](https://github.com/ajgon/opsworks_ruby/commit/b92417f))
* **source:** Subdirectories on S3 are now properly handled ([9373173](https://github.com/ajgon/opsworks_ruby/commit/9373173))
* **webserver:** Switched `chef_nginx` back to `nginx` cookbook ([683f840](https://github.com/ajgon/opsworks_ruby/commit/683f840)), closes [#148](https://github.com/ajgon/opsworks_ruby/issues/148)


### Features

* **ruby:** Added support for ruby 2.5 ([2fd887a](https://github.com/ajgon/opsworks_ruby/commit/2fd887a))
* **source:** Added support for HTTP ([34829f2](https://github.com/ajgon/opsworks_ruby/commit/34829f2))
* **source:** Added support for S3 ([019c0ad](https://github.com/ajgon/opsworks_ruby/commit/019c0ad)), closes [#133](https://github.com/ajgon/opsworks_ruby/issues/133)


### BREAKING CHANGES

* **source:** `app['scm']` has been renamed to `app['source']`. This
only affects the Custom JSON files, so if you were using this block
there, you should change it. If you were using OpsWorks git configurator
(which is probably 99.99% true), this change wouldn't affect you.




## [1.8.0](https://github.com/ajgon/opsworks_ruby/compare/v1.7.1...v1.8.0) (2017-10-23)


### Bug Fixes

* moved all pid-related files from shared/pids to /run/lock ([bc9daf0](https://github.com/ajgon/opsworks_ruby/commit/bc9daf0)), closes [#92](https://github.com/ajgon/opsworks_ruby/issues/92)
* **db:** Respect database port provided by RDS ([#124](https://github.com/ajgon/opsworks_ruby/issues/124)) ([7aeb78e](https://github.com/ajgon/opsworks_ruby/commit/7aeb78e)), closes [#123](https://github.com/ajgon/opsworks_ruby/issues/123)
* **logrotate:** remove duplicate log entry in config file generated from webserver service install ([eabf207](https://github.com/ajgon/opsworks_ruby/commit/eabf207))
* **worker:** quiet_sidekiq now uses sidekiqctl instead of kill -USR1 which is deprectaed ([1e9e32b](https://github.com/ajgon/opsworks_ruby/commit/1e9e32b)), closes [#93](https://github.com/ajgon/opsworks_ruby/issues/93)


### Features

* **scm:** Support configurable location of git_ssh_wrapper ([#121](https://github.com/ajgon/opsworks_ruby/issues/121)) ([de153bf](https://github.com/ajgon/opsworks_ruby/commit/de153bf)), closes [#120](https://github.com/ajgon/opsworks_ruby/issues/120)



## [1.7.1](https://github.com/ajgon/opsworks_ruby/compare/v1.7.0...v1.7.1) (2017-09-22)


### Bug Fixes

* **webserver:** do not unnecessarily restart webserver ([db15b26](https://github.com/ajgon/opsworks_ruby/commit/db15b26)), closes [#114](https://github.com/ajgon/opsworks_ruby/issues/114)
* **webserver:** Only remove default enabled sites ([ef085a0](https://github.com/ajgon/opsworks_ruby/commit/ef085a0)), closes [#111](https://github.com/ajgon/opsworks_ruby/issues/111)


### Features

* **webserver:** remove version info on Apache/Nginx ([6aba9f3](https://github.com/ajgon/opsworks_ruby/commit/6aba9f3))




## [1.7.0](https://github.com/ajgon/opsworks_ruby/compare/v1.6.0...v1.7.0) (2017-09-05)


### Bug Fixes

* **appserver:** passing USER and HOME environment variables to appserver process ([43210bc](https://github.com/ajgon/opsworks_ruby/commit/43210bc)), closes [#85](https://github.com/ajgon/opsworks_ruby/issues/85)
* **db:** safer migration/setup command ([19bf034](https://github.com/ajgon/opsworks_ruby/commit/19bf034)), closes [#58](https://github.com/ajgon/opsworks_ruby/issues/58)
* **overcommit:** disable fasterer warning that was causing commits to fail ([7752706](https://github.com/ajgon/opsworks_ruby/commit/7752706))
* missing databag caused maximum_override integration failure ([1be29e1](https://github.com/ajgon/opsworks_ruby/commit/1be29e1))


### Features

* **appserver+webserver:** add apache2 + passenger support ([43c61f9](https://github.com/ajgon/opsworks_ruby/commit/43c61f9))
* **database:** support null database driver ([29e1040](https://github.com/ajgon/opsworks_ruby/commit/29e1040)), closes [#98](https://github.com/ajgon/opsworks_ruby/issues/98)
* **global:** support per-application deploy directory ([28cb797](https://github.com/ajgon/opsworks_ruby/commit/28cb797)), closes [#95](https://github.com/ajgon/opsworks_ruby/issues/95)
* **logrotate:** support arbitrary logrotate customization ([fa95ab0](https://github.com/ajgon/opsworks_ruby/commit/fa95ab0)), closes [#107](https://github.com/ajgon/opsworks_ruby/issues/107)
* **webserver:** allow extensible webserver site customization ([4efd130](https://github.com/ajgon/opsworks_ruby/commit/4efd130)), closes [#100](https://github.com/ajgon/opsworks_ruby/issues/100)
* **webserver:** server_tokens off on Nginx ([#91](https://github.com/ajgon/opsworks_ruby/issues/91)) ([5568f6c](https://github.com/ajgon/opsworks_ruby/commit/5568f6c))




## [1.6.0](https://github.com/ajgon/opsworks_ruby/compare/v1.5.0...v1.6.0) (2017-06-03)


### Bug Fixes

* **ubuntu:** proper provisioning for ubuntu 16.04 ([ea5b530](https://github.com/ajgon/opsworks_ruby/commit/ea5b530)), closes [#81](https://github.com/ajgon/opsworks_ruby/issues/81)


### Features

* **webserver:** Specify upgrade method for nginx ([2624d04](https://github.com/ajgon/opsworks_ruby/commit/2624d04))
* **logrotate:** rotate all logs in app/log ([4737b49](https://github.com/ajgon/opsworks_ruby/commit/4737b49))


### BREAKING CHANGES

* Support for all legacy distributions has been dropped
off. Currently, only Ubuntu 16.04 and Amazon Linux 2017.03 are
supported.

This cookbook _should_ work on earlier versions (especially on Ubuntu),
PR with fixes to them _will_ be accepted, however the core team won't
include any patches for those distros by they own.




## [1.5.0](https://github.com/ajgon/opsworks_ruby/compare/v1.4.0...v1.5.0) (2017-04-25)


### Features

* **framework:** Allow increased timeout during deploy ([#76](https://github.com/ajgon/opsworks_ruby/issues/76)) ([e216972](https://github.com/ajgon/opsworks_ruby/commit/e216972))
* **logrotate:** implement logrotate ([86ebc10](https://github.com/ajgon/opsworks_ruby/commit/86ebc10)), closes [#78](https://github.com/ajgon/opsworks_ruby/issues/78)




## [1.4.0](https://github.com/ajgon/opsworks_ruby/compare/v1.3.0...v1.4.0) (2017-03-12)


### Bug Fixes

* Bump faraday middleware version ([d508928](https://github.com/ajgon/opsworks_ruby/commit/d508928))
* Switched `nginx` cookbook to more actively developed `chef_nginx` ([0f4f64c](https://github.com/ajgon/opsworks_ruby/commit/0f4f64c)), closes [#65](https://github.com/ajgon/opsworks_ruby/issues/65)


### Features

* **webserver:** Add app specific error log and location for nginx ([a098279](https://github.com/ajgon/opsworks_ruby/commit/a098279))
* **worker:** Safely quiet and shutdown sidekiq ([c36652f](https://github.com/ajgon/opsworks_ruby/commit/c36652f))


### BREAKING CHANGES

* `nginx` cookbook is not a `opsworks_ruby` dependency
anymore. Now it's `chef_nginx` which is more actively developed.
Please update your recipe repositories.




## [1.3.0](https://github.com/ajgon/opsworks_ruby/compare/v1.2.1...v1.3.0) (2017-01-16)


### Features

* **appserver:** Allowed deploy_before_restart on null appserver ([b0375a6](https://github.com/ajgon/opsworks_ruby/commit/b0375a6))
* **database:** Added aurora as allowed engine for mysql2 adapter ([a2789f0](https://github.com/ajgon/opsworks_ruby/commit/a2789f0))
* **ruby:** Added support for ruby 2.4 ([a89451f](https://github.com/ajgon/opsworks_ruby/commit/a89451f))


### BREAKING CHANGES

* ruby: Ruby 2.4 is now a default Ruby interpreter




## [1.2.1](https://github.com/ajgon/opsworks_ruby/compare/v1.2.0...v1.2.1) (2016-11-27)


### Bug Fixes

* Fixed broken `migration_command` default ([36cdb68](https://github.com/ajgon/opsworks_ruby/commit/36cdb68)), closes [#58](https://github.com/ajgon/opsworks_ruby/issues/58)




## [1.2.0](https://github.com/ajgon/opsworks_ruby/compare/v1.1.2...v1.2.0) (2016-11-02)


### Bug Fixes

* Moved global deploy parameters to `app['global']` section ([b4f8d6b](https://github.com/ajgon/opsworks_ruby/commit/b4f8d6b))


### BREAKING CHANGES

* `app['create_dirs_before_symlink']`, `app['purge_before_symlink']`, `app['rollback_on_error']` and `app['symlinks']`
are now `app['global']['create_dirs_before_symlink']`, `app['global']['purge_before_symlink']`,
`app['global']['rollback_on_error']` and `app['global']['symlink']`. The old format still works, but it shows
DEPRECATION warning. It will be removed in one of the next major releases.




## [1.1.2](https://github.com/ajgon/opsworks_ruby/compare/v1.1.1...v1.1.2) (2016-10-27)


### Bug Fixes

* **webserver:** Improved apache2 support ([4293bff](https://github.com/ajgon/opsworks_ruby/commit/4293bff))
* `node['applications']` are back ([5fc42c3](https://github.com/ajgon/opsworks_ruby/commit/5fc42c3)), closes [#55](https://github.com/ajgon/opsworks_ruby/issues/55)


### Features

* `app['rollback_on_error']` implemented ([e6934a7](https://github.com/ajgon/opsworks_ruby/commit/e6934a7)), closes [#54](https://github.com/ajgon/opsworks_ruby/issues/54)




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




