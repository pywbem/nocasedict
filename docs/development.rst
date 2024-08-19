
.. _`Development`:

Development
===========

This section only needs to be read by developers of the
nocasedict project,
including people who want to make a fix or want to test the project.


.. _`Repository`:

Repository
----------

The repository for the nocasedict project is on GitHub:

https://github.com/pywbem/nocasedict


.. _`Setting up the development environment`:

Setting up the development environment
--------------------------------------

1. If you have write access to the Git repo of this project, clone it using
   its SSH link, and switch to its working directory:

   .. code-block:: bash

        $ git clone git@github.com:pywbem/nocasedict.git
        $ cd nocasedict

   If you do not have write access, create a fork on GitHub and clone the
   fork in the way shown above.

2. It is recommended that you set up a `virtual Python environment`_.
   Have the virtual Python environment active for all remaining steps.

3. Install the project for development.
   This will install Python packages into the active Python environment,
   and OS-level packages:

   .. code-block:: bash

        $ make develop

4. This project uses Make to do things in the currently active Python
   environment. The command:

   .. code-block:: bash

        $ make

   displays a list of valid Make targets and a short description of what each
   target does.

.. _virtual Python environment: https://docs.python-guide.org/en/latest/dev/virtualenvs/


.. _`Building the documentation`:

Building the documentation
--------------------------

The ReadTheDocs (RTD) site is used to publish the documentation for the
project package at https://nocasedict.readthedocs.io/

This page is automatically updated whenever the Git repo for this package
changes the branch from which this documentation is built.

In order to build the documentation locally from the Git work directory,
execute:

.. code-block:: bash

    $ make builddoc

The top-level document to open with a web browser will be
``build_doc/html/docs/index.html``.


.. _`Testing`:

.. # Keep the tests/README file in sync with this 'Testing' section.

Testing
-------


All of the following `make` commands run the tests in the currently active
Python environment.

The package files that are tested are those in the `nocaselist` directory
in the main repository directory.

The test case files and any utility functions they use are always used from
the `tests` directory in the main repository directory.

The `tests` directory has the following subdirectory structure:

::

    tests
     +-- unittest            Unit tests
     +-- installtest         Installation tests

There are multiple types of tests:

1. Unit tests

   These tests can be run standalone, and the tests validate their results
   automatically.

   They are run by executing:

   .. code-block:: bash

       $ make test

   Test execution can be modified by a number of environment variables, as
   documented in the make help (execute `make help`).

2. Installation tests

   These tests can be run standalone, and the tests validate their results
   automatically.

   They are run by executing:

   .. code-block:: bash

       $ make installtest

To run the unit tests in all supported Python environments, the
Tox tool can be used. It creates the necessary virtual Python environments and
executes `make test` (i.e. the unit tests) in each of them.

For running Tox, it does not matter which Python environment is currently
active, as long as the Python `tox` package is installed in it:

.. code-block:: bash

    $ tox                              # Run tests on all supported Python versions
    $ tox -e py38                      # Run tests on Python 3.8


.. _`Contributing`:

Contributing
------------

Third party contributions to this project are welcome!

In order to contribute, create a `Git pull request`_, considering this:

.. _Git pull request: https://help.github.com/articles/using-pull-requests/

* Test is required.
* Each commit should only contain one "logical" change.
* A "logical" change should be put into one commit, and not split over multiple
  commits.
* Large new features should be split into stages.
* The commit message should not only summarize what you have done, but explain
  why the change is useful.

What comprises a "logical" change is subject to sound judgement. Sometimes, it
makes sense to produce a set of commits for a feature (even if not large).
For example, a first commit may introduce a (presumably) compatible API change
without exploitation of that feature. With only this commit applied, it should
be demonstrable that everything is still working as before. The next commit may
be the exploitation of the feature in other components.

For further discussion of good and bad practices regarding commits, see:

* `OpenStack Git Commit Good Practice`_

* `How to Get Your Change Into the Linux Kernel`_

.. _OpenStack Git Commit Good Practice: https://wiki.openstack.org/wiki/GitCommitMessages
.. _How to Get Your Change Into the Linux Kernel: https://www.kernel.org/doc/Documentation/SubmittingPatches

Further rules:

* The following long-lived branches exist and should be used as targets for
  pull requests:

  - ``master`` - for next functional version

* We use topic branches for everything!

  - Based upon the intended long-lived branch, if no dependencies

  - Based upon an earlier topic branch, in case of dependencies

  - It is valid to rebase topic branches and force-push them.

* We use pull requests to review the branches.

  - Use the correct long-lived branch (i.e. ``master``) as a merge target.

  - Review happens as comments on the pull requests.

  - At least one approval is required for merging.

* GitHub meanwhile offers different ways to merge pull requests. We merge pull
  requests by rebasing the commit from the pull request.

Releasing a version to PyPI
---------------------------

This section describes how to release a version of nocasedict
to PyPI.

It covers all variants of versions that can be released:

* Releasing a new major version (Mnew.0.0) based on the master branch
* Releasing a new minor version (M.Nnew.0) based on the master branch
* Releasing a new update version (M.N.Unew) based on the master branch

The description assumes that the `pywbem/nocasedict`
Github repo is cloned locally and its upstream repo is assumed to have the Git
remote name `origin`.

Any commands in the following steps are executed in the main directory of your
local clone of the `pywbem/nocasedict`
Git repo.

1.  Set shell variables for the version that is being released and the branch
    it is based on:

    * ``MNU`` - Full version M.N.U that is being released
    * ``MN`` - Major and minor version M.N of that full version
    * ``BRANCH`` - Name of the branch the version that is being released is
      based on

    When releasing a new major version (e.g. ``1.0.0``) based on the master
    branch:

    .. code-block:: sh

        MNU=1.0.0
        MN=1.0
        BRANCH=master

    When releasing a new minor version (e.g. ``0.9.0``) based on the master
    branch:

    .. code-block:: sh

        MNU=0.9.0
        MN=0.9
        BRANCH=master

    When releasing a new update version (e.g. ``0.8.1``) based on the master
    branch:

    .. code-block:: sh

        MNU=0.8.1
        MN=0.8
        BRANCH=master

2.  Create a topic branch for the version that is being released:

    .. code-block:: sh

        git checkout ${BRANCH}
        git pull
        git checkout -b release_${MNU}

3.  Edit the change log:

    .. code-block:: sh

        vi docs/changes.rst

    and make the following changes in the section of the version that is being
    released:

    * Finalize the version.
    * Change the release date to today's date.
    * Make sure that all changes are described.
    * Make sure the items shown in the change log are relevant for and
      understandable by users.
    * In the "Known issues" list item, remove the link to the issue tracker and
      add text for any known issues you want users to know about.
    * Remove all empty list items.

4.  Update the authors:

    .. code-block:: sh

        make authors

5.  Commit your changes and push the topic branch to the remote repo:

    .. code-block:: sh

        git commit -asm "Release ${MNU}"
        git push --set-upstream origin release_${MNU}

6.  On GitHub, create a Pull Request for branch ``release_M.N.U``. This will
    trigger the CI runs.

    When creating Pull Requests, GitHub by default targets the ``master``
    branch.

7.  On GitHub, close milestone ``M.N.U``.

8.  On GitHub, once the checks for the Pull Request for branch ``start_M.N.U``
    have succeeded, merge the Pull Request (no review is needed). This
    automatically deletes the branch on GitHub.

9.  Add a new tag for the version that is being released and push it to
    the remote repo. Clean up the local repo:

    .. code-block:: sh

        git checkout ${BRANCH}
        git pull
        git branch -D release_${MNU}
        git branch -D -r origin/release_${MNU}
        git tag -f ${MNU}
        git push -f --tags

10. On GitHub, edit the new tag ``M.N.U``, and create a release description on
    it. This will cause it to appear in the Release tab.

    You can see the tags in GitHub via Code -> Releases -> Tags.

11. Upload the package to PyPI:

    .. code-block:: sh

        make upload

    This will show the package version and will ask for confirmation.

    **Attention!** This only works once for each version. You cannot release
    the same version twice to PyPI.

    Verify that the released version arrived on PyPI at
    https://pypi.python.org/pypi/nocasedict/


Starting a new version
----------------------

This section shows the steps for starting development of a new version of the
nocasedict project in its Git repo.

This section covers all variants of new versions:

* Starting a new major version (Mnew.0.0) based on the master branch
* Starting a new minor version (M.Nnew.0) based on the master branch
* Starting a new update version (M.N.Unew) based on the master branch

The description assumes that the `pywbem/nocasedict`
Github repo is cloned locally and its upstream repo is assumed to have the Git
remote name `origin`.

Any commands in the following steps are executed in the main directory of your
local clone of the `pywbem/nocasedict`
Git repo.

1.  Set shell variables for the version that is being started and the branch it
    is based on:

    * ``MNU`` - Full version M.N.U that is being started
    * ``MN`` - Major and minor version M.N of that full version
    * ``BRANCH`` -  Name of the branch the version that is being started is
      based on

    When starting a new major version (e.g. ``1.0.0``) based on the master
    branch:

    .. code-block:: sh

        MNU=1.0.0
        MN=1.0
        BRANCH=master

    When starting a new minor version (e.g. ``0.9.0``) based on the master
    branch:

    .. code-block:: sh

        MNU=0.9.0
        MN=0.9
        BRANCH=master

    When starting a new minor version (e.g. ``0.8.1``) based on the master
    branch:

    .. code-block:: sh

        MNU=0.8.1
        MN=0.8
        BRANCH=master

2.  Create a topic branch for the version that is being started:

    .. code-block:: sh

        git fetch origin
        git checkout ${BRANCH}
        git pull
        git checkout -b start_${MNU}

3.  Edit the change log:

    .. code-block:: sh

        vi docs/changes.rst

    and insert the following section before the top-most section:

    .. code-block:: rst

        nocasedict M.N.U.dev1
        ---------------------

        Released: not yet

        **Incompatible changes:**

        **Deprecations:**

        **Bug fixes:**

        **Enhancements:**

        **Cleanup:**

        **Known issues:**

        * See `list of open issues`_.

        .. _`list of open issues`: https://github.com/pywbem/nocasedict/issues

4.  Commit your changes and push them to the remote repo:

    .. code-block:: sh

        git commit -asm "Start ${MNU}"
        git push --set-upstream origin start_${MNU}

5.  On GitHub, create a Pull Request for branch ``start_M.N.U``.

    When creating Pull Requests, GitHub by default targets the ``master``
    branch.

6.  On GitHub, create a milestone for the new version ``M.N.U``.

    You can create a milestone in GitHub via Issues -> Milestones -> New
    Milestone.

7.  On GitHub, go through all open issues and pull requests that still have
    milestones for previous releases set, and either set them to the new
    milestone, or to have no milestone.

8.  On GitHub, once the checks for the Pull Request for branch ``start_M.N.U``
    have succeeded, merge the Pull Request (no review is needed). This
    automatically deletes the branch on GitHub.

9.  Add release start tag and clean up the local repo:

    Note: An initial tag is necessary because the automatic version calculation
    done by setuptools-scm uses the most recent tag in the commit history and
    increases the least significant part of the version by one, without
    providing any controls to change that behavior.

    .. code-block:: sh

        git checkout ${BRANCH}
        git pull
        git branch -D start_${MNU}
        git branch -D -r origin/start_${MNU}
        git tag -f ${MNU}a0
        git push -f --tags
