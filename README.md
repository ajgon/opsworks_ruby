# WatchTower Benefits opsworks_ruby Cookbook
**WatchTower Benefits Chef 12 cookbook for AWS OpsWorks**

This cookbook is to be used in conjunction with AWS OpsWorks.
It is forked from the `opsworks_ruby` cookbook (forked at version [1.8.0](https://github.com/ajgon/opsworks_ruby/tree/v1.8.0)), which provides some default recipes for the AWS OpsWorks lifecycle events (setup, configure, deploy, undeploy, shutdown), as well as configuring the setup of the server.

### Cookbook Location
https://s3-us-west-2.amazonaws.com/watchtower-utilities/cookbooks.tar.gz

## AWS OpsWorks Layer Custom JSON Example
Setting custom JSON on the AWS OpsWorks layer, allows us to keep this cookbook flexible in terms of setup.
An example configuration for our `core_api` servers looks like:
```json
{
  "rbenv": {
    "ruby_version": "2.3.6"
  },
  "additional_packages": ["libcurl3", "libcurl3-gnutls", "libcurl4-openssl-dev", "zlib1g-dev", "liblzma-dev"],
  "deploy": {
    "core_api": {
      "framework": {
        "assets_precompile": false
      },
      "appserver": {
        "application_yml": true
      }
    }
  }
}
```

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

### Nginx Configuration Chanages
* Added a `/health_check` location for AWS ELB
  * This location does not force HTTPS so the ELB can hit it via HTTP
  * This location also turns on the `proxy_ignore_client_abort` flag in order to prevent the ELB from prematurely closing the connection 
* Update the `/` location to force HTTPS

## Recipes
This cookbook provides five main recipes, which should be attached to corresponding OpsWorks actions.

- `opsworks_ruby::setup` - attach to **Setup**
- `opsworks_ruby::configure` - attach to **Configure**
- `opsworks_ruby::deploy` - attach to **Deploy**
- `opsworks_ruby::undeploy` - attach to **Undeploy**
- `opsworks_ruby::shutdown` - attach to **Shutdown**

## Updating the Cookbook
In order to update the cookbook, follow the steps below:
1. Update the cookbook as necessary
2. Run `berks install` to install all packages
3. Run `berks package cookbooks.tar.gz`
4. Upload `cookbooks.tar.gz` to the `watchtower-utilities` S3 bucket at https://s3-us-west-2.amazonaws.com/watchtower-utilities/cookbooks.tar.gz.

## Original opsworks_ruby Cookbook
To view the original `opsworks_ruby` cookbook's README at the time we forked this repo, visit [https://github.com/ajgon/opsworks_ruby/blob/v1.8.0/README.md](https://github.com/ajgon/opsworks_ruby/blob/v1.8.0/README.md)
