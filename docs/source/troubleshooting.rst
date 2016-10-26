Troubleshooting
===============

Deployment fails with errors regarding application code
-------------------------------------------------------

If you have enabled ``app['framework']['envs_in_console']`` parameter, always disable it first and check if error occurs
again. This parameter is a "hack" on rails ``config/application.rb`` file, which inserts all application environment variables
before initializing the Rails stack. This may cause some problems (in very rare cases), and break this file.

SSL not working in legacy browsers
----------------------------------

By default webserver is configured to follow strict SSL security standards, `covered in this article`_. However,
old browsers (like IE < 9 or Android < 2.2) wouldn't work with this configuration very well. If your application needs
a support for those browsers, set ``app['webserver']['ssl_for_legacy_browsers']`` to true.

Some applications on my Layer deploys, some of them not
-------------------------------------------------------

Check the ``node['applications']`` parameter in :ref:`Attributes` section.
If set, it narrows down the list of applications allowed to deploy, to its value.
If not sure what to do - try to remove from your Stack/Layer config and see if this helps.

.. _covered in this article: https://cipherli.st/

