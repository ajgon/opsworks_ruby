Getting Started
===============

Super Quick Start
-----------------

This cookbook is designed to "just work". So in base case scenario, all you have to do is create
a layer and application with an optional assigned RDS data source, then add :ref:`recipes` to the corresponding OpsWorks actions.
The base scenario includes **nginx** as a web server, **puma** as application server, **Ruby on Rails** as framework,
and no extra workers (sidekiq/resque/etc.). If this okay for you, and if you configured RDS and application properly
from OpsWorks panel - you don't have to do anything else with those recipes.

Quick Start
-----------

Alternativelly, you can use a `JSON configurator`_, which is a nice tool which would help you quickly generate Stack/Layer
JSON (and hassle free). It supports, all the configuration parameters in most of the cases. If you wish to configure
multiple apps, use the generator for each one of them separately.

Full configuration
------------------

You can always create your JSON file manually, just head to the :ref:`attributes` section of this documentation, and
check which one you need.

.. _JSON configurator: http://opsworks-ruby.rzegocki.pl/configuration-builder
