# Welcome to opsworks_ruby

[opsworks\_ruby](https://github.com/ajgon/opsworks_ruby) is a set of [chef](https://www.chef.io/) recipes to ease
the deployment to [AWS OpsWorks](https://aws.amazon.com/opsworks/) service. It was created, when
[Amazon introduced Chef 12 to OpsWorks stack](https://blogs.aws.amazon.com/application-management/post/Tx1T5HNA1TSU8NH/AWS-OpsWorks-Now-Supports-Chef-12-for-Linux)
without support for any chef recipes. The main goal of this project is to mimic Chef 11 OpsWorks stack as close as possible.

The code is open source, and [available on github](https://github.com/ajgon/opsworks_ruby).

The main documentation for the site is organized into a couple sections:

- [User Documentation](#user-documentation)
- [Cookbook Documentation](#cookbook-documentation)
- [About opsworks\_ruby](#about-opsworks_ruby)

## User Documentation

- [Getting Started](getting-started.md)
    - [Super Quick Start](getting-started.md#super-quick-start)
    - [Quick Start](getting-started.md#quick-start)
    - [Full configuration](getting-started.md#full-configuration)
- [Troubleshooting](troubleshooting.md)
    - [Deployment fails with errors regarding application code](troubleshooting.md#deployment-fails-with-errors-regarding-application-code)
    - [SSL not working in legacy browsers](troubleshooting.md#ssl-not-working-in-legacy-browsers)

## Cookbook Documentation

- [Supported Technologies](support.md)
- [Requirements](requirements.md)
    - [Cookbooks](requirements.md#cookbooks)
    - [Platform](requirements.md#platform)
- [Attributes](attributes.md)
    - [basic](attributes.md#basic)
    - [global](attributes.md#global)
    - [database](attributes.md#database)
    - [scm](attributes.md#scm)
    - [framework](attributes.md#framework)
    - [appserver](attributes.md#appserver)
    - [webserver](attributes.md#webserver)
- [Recipes](recipes.md)

## About opsworks_ruby

- [Contributing](contributing.md)
    - [Pull Requests](contributing.md#pull-requests)
    - [Running Tests](contributing.md#running-tests)
- [Author and Contributors](team.md)
    - [Author](team.md#author)
    - [Contributors](team.md#contributors)
- [Changelog](changelog.md)
- [License](license.md)
