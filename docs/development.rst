
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
Depending on how the `nocasedict` package is installed in
that Python environment, either the directories in the main repository
directory are used, or the installed package.
The test case files and any utility functions they use are always used from
the `tests` directory in the main repository directory.

The `tests` directory has the following subdirectory structure:

::

    tests
     +-- unittest            Unit tests

There are multiple types of tests:

1. Unit tests

   These tests can be run standalone, and the tests validate their results
   automatically.

   They are run by executing:

   .. code-block:: bash

       $ make test

   Test execution can be modified by a number of environment variables, as
   documented in the make help (execute `make help`).

   An alternative that does not depend on the makefile and thus can be executed
   from the source distribution archive, is:

   .. code-block:: bash

       $ ./setup.py test

   Options for pytest can be passed using the ``--pytest-options`` option.


To run the unit tests in all supported Python environments, the
Tox tool can be used. It creates the necessary virtual Python environments and
executes `make test` (i.e. the unit tests) in each of them.

For running Tox, it does not matter which Python environment is currently
active, as long as the Python `tox` package is installed in it:

.. code-block:: bash

    $ tox                              # Run tests on all supported Python versions
    $ tox -e py27                      # Run tests on Python 2.7


.. _`Testing from the source archives on Pypi or GitHub`:

Testing from the source archives on Pypi or GitHub
--------------------------------------------------

The wheel distribution archives on Pypi (e.g. ``*.whl``) contain only the
files needed to run this package, but not the files needed to test it.

The source distribution archives on Pypi and GitHub (e.g. ``*.tar.gz``)
contain all files that are needed to run and to test this package. This allows
testing the package without having to check out the entire repository, and is
convenient for testing e.g. when packaging into OS-level packages.
Nevertheless, the test files are not installed when installing these source
distribution archives.

The following commands download the source distribution archive on Pypi for a
particular version of the package into the current directory and unpack it:

.. code-block:: bash

    $ pip download --no-deps --no-binary :all: nocasedict==1.0.0
    $ tar -xf nocasedict-1.0.0.tar.gz
    $ cd nocasedict-1.0.0
    $ ls -1
    -rw-r--r--   1 johndoe  staff    468 Jun 29 22:31 INSTALL.md
    -rw-r--r--   1 johndoe  staff  26436 May 26 06:45 LICENSE.txt
    -rw-r--r--   1 johndoe  staff    367 Jul  3 07:54 MANIFEST.in
    -rw-r--r--   1 johndoe  staff   3451 Jul  3 07:55 PKG-INFO
    -rw-r--r--   1 johndoe  staff   7665 Jul  2 23:20 README.rst
    drwxr-xr-x  29 johndoe  staff    928 Jul  3 07:55 nocasedict
    drwxr-xr-x   8 johndoe  staff    256 Jul  3 07:55 nocasedict.egg-info
    -rw-r--r--   1 johndoe  staff   1067 Jun 29 22:31 requirements.txt
    -rw-r--r--   1 johndoe  staff     38 Jul  3 07:55 setup.cfg
    -rwxr-xr-x   1 johndoe  staff   7555 Jul  3 07:24 setup.py
    -rw-r--r--   1 johndoe  staff   2337 Jul  2 23:20 test-requirements.txt
    drwxr-xr-x  15 johndoe  staff    480 Jul  3 07:55 tests

This package, its dependent packages for running it, and its dependent packages
for testing it can be installed with the package extra named "test":

.. code-block:: bash

    $ pip install .[test]

When testing in Linux distributions that include this package as an OS-level
package, the corresponding OS-level packages would instead be installed for
these dependent Python packages. The ``test-requirements.txt`` file shows which
dependent Python packages are needed for testing this package.

Finally, the tests can be run using the ``setup.py`` script:

.. code-block:: bash

    $ ./setup.py test

These commands are listed in the help of the ``setup.py`` script:

.. code-block:: bash

    $ ./setup.py --help-commands

    . . .

    Extra commands:
      . . .
      test              Run unit tests using pytest
      . . .

The additional options supported by these commands are shown in their help:

.. code-block:: bash

    $ ./setup.py test --help

    . . .

    Options for 'test' command:
      --pytest-options  additional options for pytest, as one argument

    . . .

Note: The ``test`` command of ``setup.py`` is not the deprecated built-in
command (see `<https://github.com/pypa/setuptools/issues/1684>`_), but has been
implemented in ``setup.py`` in such a way that it only runs the tests but
does not install anything upfront.
Therefore, this approach can be used for testing in Linux distributions that
include this package as an OS-level package.


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

  - ``stable_$MN`` - for fix stream of released version M.N.

* We use topic branches for everything!

  - Based upon the intended long-lived branch, if no dependencies

  - Based upon an earlier topic branch, in case of dependencies

  - It is valid to rebase topic branches and force-push them.

* We use pull requests to review the branches.

  - Use the correct long-lived branch (e.g. ``master`` or ``stable_0.2``) as a
    merge target.

  - Review happens as comments on the pull requests.

  - At least one approval is required for merging.

* GitHub meanwhile offers different ways to merge pull requests. We merge pull
  requests by rebasing the commit from the pull request.

Releasing a version to PyPI
---------------------------

This section describes how to release a version of nocasedict
to PyPI.

It covers all variants of versions:

* Releasing the master branch as a new (major or minor) version

* Releasing a fix stream branch of an already released version as a new fix
  version

The description assumes that the project repo is cloned locally.
Their upstream repos are assumed to have the remote name ``origin``.

1.  Switch to your work directory of the project repo (this is where
    the ``Makefile`` is), and perform the following steps in that directory.

2.  Set shell variables for the version and branch to be released.

    When releasing the master branch:

    .. code-block:: bash

        $ MNP="0.2.0"          # Full version number M.N.P of version to be released
        $ MN="0.2"             # Major and minor version number M.N of version to be released
        $ BRANCH="master"      # Branch to be released

    When releasing a fix stream branch:

    .. code-block:: bash

        $ MNP="0.1.1"          # Full version number M.N.P of version to be released
        $ MN="0.1"             # Major and minor version number M.N of version to be released
        $ BRANCH="stable_$MN"  # Branch to be released

3.  Check out the branch to be released, make sure it is up to date with
    upstream, and create a topic branch for the version to be released:

    .. code-block:: bash

        $ git checkout $BRANCH
        $ git pull
        $ git checkout -b release_$MNP

4.  Edit the version file:

    .. code-block:: bash

        $ vi nocasedict/_version.py

    and set the version to be released:

    .. code-block:: text

        __version__ = 'M.N.P'

    where M.N.P is the version to be released, e.g. `0.2.0`.

    You can verify that this version is picked up by setup.py as follows:

    .. code-block:: bash

        $ ./setup.py --version
        0.2.0

5.  Edit the change log:

    .. code-block:: bash

        $ vi docs/changes.rst

    To make the following changes for the version to be released:

    * Finalize the version to the version to be released.

    * Remove the statement that the version is in development.

    * Update the statement which fixes of the previous stable version
      are contained in this version.  If there is no fix release
      of the previous stable version, the line can be removed.

    * Change the release date to today´s date.

    * Make sure that all changes are described. This can be done by comparing
      the changes listed with the commit log of the master branch.

    * Make sure the items in the change log are relevant for and understandable
      by users of the project.

    * In the "Known issues" list item, remove the link to the issue tracker
      and add text for any known issues you want users to know about.

      Note: Just linking to the issue tracker quickly becomes incorrect for a
      released version and is therefore only good during development of a
      version. In the "Starting a new version" section, the link will be added
      again for the new version.

6.  Perform a complete build (in your favorite Python virtual environment):

    .. code-block:: bash

        $ make clobber
        $ make all

    If this fails, fix and iterate over this step until it succeeds.

7.  Commit the changes and push to upstream:

    .. code-block:: bash

        $ git status    # to double check which files have been changed
        $ git commit -asm "Release $MNP"
        $ git push --set-upstream origin release_$MNP

8.  On GitHub, create a Pull Request for branch ``release_$MNP``. This will
    trigger the CI runs in Travis and Appveyor.

    Important: When creating Pull Requests, GitHub by default targets
    the ``master`` branch. If you are releasing a fix version, you need to
    change the target branch of the Pull Request to ``stable_$MN``.

9.  Perform a complete test using Tox:

    .. code-block:: bash

        $ tox

    This will create virtual Python environments for all supported Python
    versions that are installed on your system and will invoke ``make test``
    in each of them.

10. If any of the tests mentioned above fails, fix the problem and iterate
    back to step 6. until they all succeed.

11. On GitHub, once the CI runs for the Pull Request succeed:

    - Merge the Pull Request (no review is needed)

    - Delete the branch of the Pull Request (``release_$MNP``)

12. Checkout the branch you are releasing, update it from upstream, and
    delete the local topic branch you created:

    .. code-block:: bash

        $ git checkout $BRANCH
        $ git pull
        $ git branch -d release_$MNP

13. Tag the version:

    This step tags the local repo and pushes it upstream:

    .. code-block:: bash

        $ git status    # double check that the branch to be released (`$BRANCH`) is checked out
        $ git tag $MNP
        $ git push --tags

14. If you released the master branch it will be fixed separately, so it needs
    a new fix stream.

    * Create a branch for its fix stream and push it upstream:

      .. code-block:: bash

          $ git status    # double check that the branch to be released (`$BRANCH`) is checked out
          $ git checkout -b stable_$MN
          $ git push --set-upstream origin stable_$MN

    * Log on to `RTD <https://readthedocs.org/>`_, go to the project,
      and activate the new branch ``stable_$MN`` as a version to be built.

15. On GitHub, edit the new tag, and create a release description on it. This
    will cause it to appear in the Release tab.

16. On GitHub, close milestone M.N.P.

    Note: Issues with that milestone will be moved forward in the section
    "Starting a new version".

17. Upload the package to PyPI:

    .. code-block:: bash

        $ make upload

    **Attention!!** This only works once. You cannot re-release the same
    version to PyPI.

    Verify that it arrived on PyPI: https://pypi.python.org/pypi/nocasedict/

Starting a new version
----------------------

This section shows the steps for starting development of a new version of the
nocasedict project in its Git repo.

It covers all variants of new versions:

* A new (major or minor) version for new development based upon the master
  branch.

* A new fix version based on a ``stable_$MN`` fix stream branch.

1.  Switch to the work directory of your repo clone and perform the following
    steps in that directory.

2.  Set shell variables for the version to be started and for the branch it is
    based upon.

    When starting a new major or minor version based on the master branch:

    .. code-block:: bash

        $ MNP="0.2.0"          # Full version number M.N.P of version to be started
        $ MN="0.2"             # Major and minor version number M.N of version to be started
        $ BRANCH="master"      # Branch the new version is based on

    When releasing a fix version based on a fix stream branch:

    .. code-block:: bash

        $ MNP="0.1.1"          # Full version number M.N.P of version to be started
        $ MN="0.1"             # Major and minor version number M.N of version to be started
        $ BRANCH="stable_$MN"  # Branch the new version is based on

3.  Check out the branch the new version is based upon, make sure it is up to
    date with upstream, and create a topic branch for the new version:

    .. code-block:: bash

        $ git checkout $BRANCH
        $ git pull
        $ git checkout -b start_$MNP

4.  Edit the version file:

    .. code-block:: bash

        $ vi nocasedict/_version.py

    and set the version to the new development version:

    .. code-block:: text

        __version__ = 'M.N.P.dev1'

    where M.N.P is the new version to be started, e.g. `0.2.0`.

5.  Edit the change log:

    .. code-block:: bash

        $ vi docs/changes.rst

    To insert the following section before the top-most section:

    .. code-block:: text

        nocasedict 0.2.0.dev1
        ------------------------------------------

        This version contains all fixes up to nocasedict 0.1.x.

        Released: not yet

        **Incompatible changes:**

        **Deprecations:**

        **Bug fixes:**

        **Enhancements:**

        **Cleanup:**

        **Known issues:**

        * See `list of open issues`_.

        .. _`list of open issues`: https://github.com/pywbem/nocasedict/issues

6.  Commit the changes and push to upstream:

    .. code-block:: bash

        $ git status    # to double check which files have been changed
        $ git commit -asm "Start $MNP"
        $ git push --set-upstream origin start_$MNP

7.  On Github, create a Pull Request for branch ``start_$MNP``.

    Important: When creating Pull Requests, GitHub by default targets
    the master branch. If you are starting a fix version, you need to
    change the target branch of the Pull Request to ``stable_$MN``.

8.  On GitHub, once all of these tests succeed:

    - Merge the Pull Request (no review is needed)

    - Delete the branch of the Pull Request (``release_$MNP``)

9.  Checkout the branch the new version is based upon, update it from
    upstream, and delete the local topic branch you created:

    .. code-block:: bash

        $ git checkout $BRANCH
        $ git pull
        $ git branch -d start_$MNP

10. On GitHub, create a new milestone M.N.P for the version that is started.

11. On GitHub, list all open issues that still have a milestone of less than
    M.N.P set, and update them as needed to target milestone M.N.P.
