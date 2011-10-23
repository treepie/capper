======
capper
======

:Author: `Benedikt Böhm <bb@xnull.de>`_
:Web: http://github.com/zenops/capper
:Git: ``git clone https://github.com/zenops/capper``

Capper is a collection of opinionated Capistrano recipes.

Rationale
=========

Most Ruby (on Rails) applications are deployed the same way. While capistrano
itself is already quite opinionated, maintaining a multitude of applications
feels like copy&paste very fast.

Capper provides sane defaults and many recipes for technologies typically used
with Ruby (on Rails) deployments to make ``config/deploy.rb`` much more
declarative and terse.

Usage
=====

Capper recipes should be loaded via ``Capfile`` like this::

  require "capper"

  load "capper/git"
  load "capper/rails"
  load "capper/unicorn"

  load "config/deploy"

  load "capper/multistage"

Note: capper takes care of loading capistranos default deploy recipe, no need
to load it again in your ``Capfile``.

Multistage
----------

Capper provides a clean DSL syntax for multistage support. In contrast to
capistrano-ext you don't have to create a bunch of tiny files in
``config/deploy/`` but instead use DSL sugar in ``config/deploy.rb``::

  stage :production do
    server "app1.example.com", :app, :db, :primary => true
    server "app2.example.com", :app
  end

  stage :staging do
    server "staging.example.com", :app, :db, :primary => true
    set :rails_env, "staging"
    set :branch, "staging"
  end

Note: the multistage recipe must be loaded after ``config/deploy`` otherwise
it cannot know the defined stages.

Templates
---------

Capper provides a powerful yet simple mechanism to upload scripts and config
files rendered from templates during deploy. Template files are stored in
``config/deploy/templates`` but are rarely needed since capper recipes already
contain required template files.

To upload a custom template create an ERb file and upload it with
``upload_template_file``::

  upload_template_file("myscript.sh", "#{bin_path}/myscript", :mode => "0755")

The above command will upload ``config/deploy/templates/myscript.sh.erb`` to
the specified path. Inside the template all capistrano options (current_path,
application, etc) are available.

Monit integration
-----------------

Capper provides DSL syntax for monit integration. Many recipes shipped with
capper already contain monit configuration. These configuration snippets are
not enabled unless you include the monit recipe in your ``Capfile``.

Custom monit configuration snippets can be created with ``monit_config``::

  monit_config "myprocess", <<EOF, :roles => :app
  check process myprocess
  with pidfile ...
  start program = ...
  stop program = ...
  EOF

The above call will create the specified monit snippet for monit instances
running on servers in the ``:app`` role.

Recipes
=======

The following recipes are included in capper.

base
----

The base recipe is automatically loaded and provides the basic opinions capper
has about deployment:

- The application is deployed to a dedicated user account with the same name as
  the application.

- The parent path for these user accounts defaults to ``/var/app``.

- No sudo privileges are ever needed.

- Releases are cleaned up by default.

Additionally a ``deploy:symlink`` task is provided to make symlinks declarative
in ``config/deploy.rb``::

  set :symlink, {
    "config/database.yml" => "config/database.yml",
    "shared/uploads" => "public/uploads"
  }

The above snippet will create symlinks from
``#{shared_path}/config/database.yml`` to
``#{release_path}/config/database.yml`` and from
``#{shared_path}/uploads`` to
``#{release_path}/public/uploads`` after ``deploy:update_code`` has run.


bundler
-------

The bundler recipe is an extension of bundlers native capistrano integration:

- During ``deploy:setup`` it is ensured that a known-to-work bundler version
  (specified via ``bundler_version``) is installed.

- When used together with the rvm recipe bundles are not installed globally to
  ``shared/bundle`` but instead a gemset specific location is used
  (``shared/bundle/#{gemset}``).

- The option ``ruby_exec_prefix`` is set to ``bundle exec`` for convenience.

config
------

The config recipe adds support for a dedicated repository with configuration
files. It is very preliminary right now and only supports git. The repository
specified with ``config_repo`` will be cloned into ``shared/config`` and all
files specified in the ``config_files`` array are copied to
``#{release_path}/config``.

delayed_job
-----------

The delayed_job recipe provides integration with DelayedJob. A script to
start/stop delayed job workers is uploaded to ``#{bin_path}/delayed_job``. The
script supports multiple instances and priority ranges.

If monit integration has been enabled via ``capper/monit`` workers are
automatically (re)started during deploy and can be specified via
``delayed_job_workers``::

  set :delayed_jobs_workers, {
    :important => 0..1,
    :worker1 => 2..10,
    :worker2 => 2..10
  }

git
---

The git recipe will simply set capistrano to use the git strategy with
remote_cache::

  set(:scm, :git)
  set(:deploy_via, :remote_cache)

hoptoad
-------

The hoptoad recipe is merely a copy of hoptoads native capistrano integration
without after/before hooks, so hoptoad notifications can be enabled on-demand
in stage blocks::

  stage :production do
    ...
    after "deploy", "hoptoad:notify"
  end

monit
-----

The monit recipe will collect all snippets declared via ``monit_config`` and
render them into the file specified via ``monitrc`` (default:
``~/.monitrc.local``, this file should be included in your ``~/.monitrc``).

rails
-----

The rails recipe sets the default ``rails_env`` to production and includes
tasks for deploying the asset pipeline for rails 3.1 applications. The recipe
will automatically determine if your asset timestamps need to be normalized.

resque
------

The resque recipe provides integration with Resque. A script to
start/stop resque workers is uploaded to ``#{bin_path}/resque``. The
script supports multiple instances with queue names.

If monit integration has been enabled via ``capper/monit`` workers are
automatically (re)started during deploy and can be specified via
``resque_workers``::

  set :resque_workers, {
    :important => :important,
    :worker1 => :default,
    :worker2 => :default
  }

rvm
---

The rvm recipe is an extension to RVMs native capistrano integration. The
recipe forces the ``rvm_type`` to ``:user`` and will automatically determine
the ruby version and gemset via the projects ``.rvmrc``.

A ``deploy:setup`` hook is provided to ensure the correct ruby and rubygems
version is installed on all servers.

unicorn
-------

The unicorn recipe provides integration with Unicorn. A script to manage the
unicorn process is uploaded to ``#{bin_path}/unicorn``. Additionally this
recipe also manages the unicorn configuration file (in ``config/unicorn.rb``).

If monit integration has been enabled via ``capper/monit`` unicorn is
automatically (re)started during ``deploy:restart`` using unicorns in-place,
no-downtime upgrade method.

The following configuration options are provided:

``unicorn_worker_processes``
  Number of unicorn workers (default: 4)

``unicorn_timeout``
  Timeout after which workers are killed (default: 30)

whenever
--------

The whenever recipe is a simplified version of whenevers native capistrano
integration. With one application per user account the whole crontab can be
used for whenever. Additionally this recipe take the ``ruby_exec_prefix``
setting into account.

Contributing to capper
======================

- Check out the latest master to make sure the feature hasn't been implemented
  or the bug hasn't been fixed yet

- Check out the issue tracker to make sure someone already hasn't requested it
  and/or contributed it

- Fork the project

- Start a feature/bugfix branch

- Commit and push until you are happy with your contribution

Copyright
=========

Copyright (c) 2011 Benedikt Böhm. See LICENSE.txt for
further details.
