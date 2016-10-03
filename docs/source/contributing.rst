Contributing
============

Contributions are **welcome** and will be fully **credited**.

We accept contributions via Pull Requests on `Github`_.

Pull Requests
-------------

-  **Lint your code** - The easiest way to apply the conventions is to install `overcommit`_.
-  **Add tests!** - Your patch won’t be accepted if it doesn’t have tests.
-  **Document any change in behaviour** - Make sure the README and any other relevant documentation are kept up-to-date.
-  **Consider our release cycle** - We try to follow `semver`_. Randomly breaking public APIs is not an option.
-  **Create topic branches** - Don’t ask us to pull from your master branch.
-  **One pull request per feature** - If you want to do more than one thing, send multiple pull requests.
-  **Send coherent history** - Make sure each individual commit in your pull request is meaningful.
   If you had to make multiple intermediate commits while developing, please squash them before submitting.
-  **Commit convention** - We follow `AngularJS Git Commit Message Conventions`_

Running Tests
-------------

Ensure, that you have `Chef DK`_ installed.

.. code:: bash

    bundle exec overcommit -r
    chef exec rspec

**Happy coding!**

.. _Github: https://github.com/ajgon/opsworks_ruby
.. _overcommit: https://github.com/brigade/overcommit
.. _semver: http://semver.org
.. _AngularJS Git Commit Message Conventions: https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit#
.. _Chef DK: https://downloads.chef.io/chef-dk/
