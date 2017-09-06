# Releasing opsworks\_ruby

## Checklist

1. Make changes
1. Commit those changes
1. Make sure Travis turns green
1. Make sure Coverage remains 100%
1. Bump version in `package.json`
1. Bump version in `metadata.rb`
1. Bump version in `docs/source/config.py`
1. Add contributors to `README.md` and `docs/source/team.rst` if necessary
1. `echo -n "<your chef login>"` > .chef.login
1. Put your chef private key associated with `opsworks_ruby` cookbook as `client.pem`
   file into project directory
1. `docker-compose build`
1. `docker-compose run cookbook sh -c "conventional-changelog -s -p angular -i CHANGELOG.md"`
1. Commit all the things with `chore: Version bump`
1. Add new configuration options to `gh-pages-source` if necessary
1. Tag version
1. Push: `git push origin master --tags`
1. `docker-compose run cookbook knife cookbook site share opsworks_ruby Applications`
1. Draft new release on GitHub

## Solving problems with knife

In case of trouble, check [Sharing Chef Cookbooks](http://fabiorehm.com/blog/2013/10/01/sharing-chef-cookbooks/)
article. Short version:

### WARNING: No knife configuration file found

```shell
$ knife cookbook site share opsworks_ruby Applications
WARNING: No knife configuration file found
ERROR: Chef::Exceptions::CookbookNotFoundInRepo: Cannot find a cookbook named opsworks_ruby;
did you forget to add metadata to a cookbook? (http://wiki.opscode.com/display/chef/Metadata)
```

Solution:

```shell
% echo client_key \"#{ENV['HOME']}/.chef/client.pem\" >> ~/.chef/knife.rb
% echo cookbook_path \"#{ENV['HOME']}/Projects/cookbooks\" >> ~/.chef/knife.rb
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

### ERROR: Authentication failed due to an invalid public/private key pair

```shell
docker run -it --rm --privileged --pid=host opsworksruby_cookbook \
       nsenter -t 1 -m -u -n -i date -u $(date -u +%m%d%H%M%Y)
```

### ERROR: Error uploading cookbook opsworks_ruby to the Opscode Cookbook Site

```shell
% knife cookbook site share opsworks_ruby Applications
Generating metadata for opsworks_ruby from /tmp/chef-opsworks_ruby-build20161021-18021-ypq6jp/opsworks_ruby/metadata.rb
Making tarball opsworks_ruby.tgz
ERROR: Error uploading cookbook opsworks_ruby to the Opscode Cookbook Site:
undefined method `strip' for nil:NilClass.
Set log level to debug (-l debug) for more information.`
```

Solution:

```shell
% echo node_name \"<your chef login>\" >> ~/.chef/knife.rb
```
