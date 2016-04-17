# Contributing

Contributions are **welcome** and will be fully **credited**.

We accept contributions via Pull Requests on [Github][1].

## Pull Requests

- **Lint your code** - The easiest way to apply the conventions is to install
  [overcommit][2].

- **Add tests!** - Your patch won't be accepted if it doesn't have tests.

- **Document any change in behaviour** - Make sure the README and any other
  relevant documentation are kept up-to-date.

- **Consider our release cycle** - We try to follow [semver][3]. Randomly
  breaking public APIs is not an option.

- **Create topic branches** - Don't ask us to pull from your master branch.

- **One pull request per feature** - If you want to do more than one thing,
  send multiple pull requests.

- **Send coherent history** - Make sure each individual commit in your pull
  request is meaningful. If you had to make multiple intermediate commits while
  developing, please squash them before submitting.

## Running Tests

Ensure, that you have [Chef DK][4] installed.

```
bundle exec overcommit -r
chef exec rspec
```

**Happy coding**!

[1]: https://github.com/ajgon/opsworks_ruby
[2]: https://github.com/brigade/overcommit
[3]: http://semver.org
[4]: https://downloads.chef.io/chef-dk/
