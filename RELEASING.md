# Releasing opsworks\_ruby

## Checklist

1. Make changes
1. Commit those changes
1. Make sure Travis turns green
1. Make sure Coverage remains 100%
1. Bump version in `package.json`
1. Bump version in `metadata.rb`
1. Bump version in `docs/source/config.py`
1. `conventional-changelog -p angular -i CHANGELOG.md -s`
1. Commit all the things with `chore: Version bump`
1. Tag version
1. Push: `git push origin master --tags`
1. `knife cookbook site share opsworks_ruby Applications`

## Solving problems with knife

In case of trouble, check [Sharing Chef Cookbooks](http://fabiorehm.com/blog/2013/10/01/sharing-chef-cookbooks/)
article. Short version:

### WARNING: No knife configuration file found

```shell
$ knife cookbook site share opsworks_ruby Applications
WARNING: No knife configuration file found
ERROR: Chef::Exceptions::CookbookNotFoundInRepo: Cannot find a cookbook named dokku;
did you forget to add metadata to a cookbook? (http://wiki.opscode.com/display/chef/Metadata)
```

Solution:

```shell
% echo client_key \"#{ENV['HOME']}/.chef/client.pem\" >> ~/.chef/knife.rb
% cookbook_path \"#{ENV['HOME']}/Projects/cookbooks\" >> ~/.chef.knife.rb
```

### ERROR: Errno::EACCES: Permission denied - /var/chef

```shell
% knife cookbook site share opsworks_ruby Applications
ERROR: Errno::EACCES: Permission denied - /var/chef
```

Solution:

```shell
% sudo chown -R $USER /var/chef
```

### ERROR: Error uploading cookbook dokku to the Opscode Cookbook Site

```shell
% knife cookbook site share opsworks_ruby Applications
Generating metadata for dokku from /tmp/chef-opsworks_ruby-build20161021-18021-ypq6jp/opsworks_ruby/metadata.rb
Making tarball dokku.tgz
ERROR: Error uploading cookbook dokku to the Opscode Cookbook Site:
undefined method `strip' for nil:NilClass.
Set log level to debug (-l debug) for more information.`
```

Solution:

```shell
% echo node_name \"$USER\" >> ~/.chef/knife.rb
```
