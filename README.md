# WatchTower Benefits opsworks_ruby Cookbook
This is a fork of the [opsworks_ruby](https://github.com/ajgon/opsworks_ruby) cookbook, forked at version 1.8.0.
This cookbook is being used to provision our AWS OpsWorks servers.

## Changes from opsworks_ruby cookbook

### Support installing additional packages via OpsWorks custom JSON
In order to install additinal packages, simply add an array of packages to your custom JSON as `node['additional_packages']`
```json
{
  "additional_packages": ["libcurl3", "libcurl3-gnutls", "libcurl4-openssl-dev", "zlib1g-dev", "liblzma-dev"] 
}
``` 

### Support for using rbenv instead of ruby-ng
In order to install rbenv, with the Ruby version of your choice, add `node['rbenv']['ruby_version']` to you OpsWorks custom JSON
```json
{
  "rbenv": {
    "ruby_version": "2.3.6"
  }
}
``` 
Currently, rbenv support is implemented with Rails as the framework, and Puma as the app server.
Due to this, if we end up using this recipe for another Ruby framework or we want to switch app servers, we will need to add in support for rbenv in those library files.
We are currently using nginx as the web server, but no changes were made there, so switching web servers should be straightforward.

# opsworks_ruby Cookbook
To view the original `opsworks_ruby` cookbook's README at the time we forked this repo, visit [https://github.com/ajgon/opsworks_ruby/blob/v1.8.0/README.md](https://github.com/ajgon/opsworks_ruby/blob/v1.8.0/README.md)
