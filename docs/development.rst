
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
    $ tox -e py313                     # Run tests on Python 3.13


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


.. _`Releasing a version`:

Releasing a version
-------------------

This section describes how to release a version of nocasedict to PyPI.

It covers all variants of versions that can be released:

* Releasing a new major version (Mnew.0.0) based on the master branch
* Releasing a new minor version (M.Nnew.0) based on the master branch
* Releasing a new update version (M.N.Unew) based on the stable branch of its
  minor version

This description assumes that you are authorized to push to the remote repo
at https://github.com/pywbem/nocasedict and that the remote repo
has the remote name ``origin`` in your local clone.

Any commands in the following steps are executed in the main directory of your
local clone of the ``pywbem/nocasedict`` Git repo.

1.  On GitHub, verify open items in milestone ``M.N.U``.

    Verify that milestone ``M.N.U`` has no open issues or PRs anymore. If there
    are open PRs or open issues, make a decision for each of those whether or
    not it should go into version ``M.N.U`` you are about to release.

    If there are open issues or PRs that should go into this version, abandon
    the release process.

    If none of the open issues or PRs should go into this version, change their
    milestones to a future version, and proceed with the release process. You
    may need to create the milestone for the future version.

2.  Run the Safety tool:

    .. code-block:: sh

        make safety

    If any of the two safety runs fails, fix the safety issues that are reported,
    in a separate branch/PR.

    Roll back the PR into any maintained stable branches.

3.  Check for any
    `dependabot alerts <https://github.com/pywbem/nocasedict/security/dependabot>`_.

    If there are any dependabot alerts, fix them in a separate branch/PR.

    Roll back the PR into any maintained stable branches.

4.  Create and push the release branch (replace M,N,U accordingly):

    .. code-block:: sh

        VERSION=M.N.U make release_branch

    This uses the default branch determined from ``VERSION``: For ``M.N.0``,
    the ``master`` branch is used, otherwise the ``stable_M.N`` branch is used.
    That covers for all cases except if you want to release a new minor version
    based on an earlier stable branch. In that case, you need to specify that
    branch:

    .. code-block:: sh

        VERSION=M.N.0 BRANCH=stable_M.N make release_branch

    This includes the following steps:

    * create the release branch (``release_M.N.U``), if it does not yet exist
    * make sure the AUTHORS.md file is up to date
    * update the change log from the change fragment files, and delete those
    * commit the changes to the release branch
    * push the release branch

    If this command fails, the fix can be committed to the release branch
    and the command above can be retried.

5.  On GitHub, create a Pull Request for branch ``release_M.N.U``.

    Important: When creating Pull Requests, GitHub by default targets the
    ``master`` branch. When releasing based on a stable branch, you need to
    change the target branch of the Pull Request to ``stable_M.N``.

    Set the milestone of that PR to version ``M.N.U``.

    This PR should normally be set to be reviewed by at least one of the
    maintainers.

    The PR creation will cause the "test" workflow to run. That workflow runs
    tests for all defined environments, since it discovers by the branch name
    that this is a PR for a release.

6.  On GitHub, once the checks for that Pull Request have succeeded, merge the
    Pull Request (no review is needed). This automatically deletes the branch
    on GitHub.

    If the PR did not succeed, fix the issues.

7.  On GitHub, close milestone ``M.N.U``.

    Verify that the milestone has no open items anymore. If it does have open
    items, investigate why and fix (probably step 1 was not performed).

8.  Publish the package (replace M,N,U accordingly):

    .. code-block:: sh

        VERSION=M.N.U make release_publish

    or (see step 4):

    .. code-block:: sh

        VERSION=M.N.0 BRANCH=stable_M.N make release_publish

    This includes the following steps:

    * create and push the release tag
    * clean up the release branch

    Pushing the release tag will cause the "publish" workflow to run. That workflow
    builds the package, publishes it on PyPI, creates a release for it on
    GitHub, and finally creates a new stable branch on GitHub if the master
    branch was released.

11. Verify the publishing

    Wait for the "publish" workflow for the new release to have completed:
    https://github.com/pywbem/nocasedict/actions/workflows/publish.yml

    Then, perform the following verifications:

    * Verify that the new version is available on PyPI at
      https://pypi.python.org/pypi/nocasedict/

    * Verify that the new version has a release on Github at
      https://github.com/pywbem/nocasedict/releases

    * Verify that the new version has documentation on ReadTheDocs at
      https://nocasedict.readthedocs.io/en/stable/changes.html

      The new version M.N.U should be automatically active on ReadTheDocs,
      causing the documentation for the new version to be automatically built
      and published.

      If you cannot see the new version after some minutes, log in to
      https://readthedocs.org/projects/nocasedict/versions/ and activate
      the new version.


.. _`Starting a new version`:

Starting a new version
----------------------

This section shows the steps for starting development of a new version.

This section covers all variants of new versions:

* Starting a new major version (Mnew.0.0) based on the master branch
* Starting a new minor version (M.Nnew.0) based on the master branch
* Starting a new update version (M.N.Unew) based on the stable branch of its
  minor version

This description assumes that you are authorized to push to the remote repo
at https://github.com/pywbem/nocasedict and that the remote repo
has the remote name ``origin`` in your local clone.

Any commands in the following steps are executed in the main directory of your
local clone of the ``pywbem/nocasedict`` Git repo.

1.  Create and push the start branch (replace M,N,U accordingly):

    .. code-block:: sh

        VERSION=M.N.U make start_branch

    This uses the default branch determined from ``VERSION``: For ``M.N.0``,
    the ``master`` branch is used, otherwise the ``stable_M.N`` branch is used.
    That covers for all cases except if you want to start a new minor version
    based on an earlier stable branch. In that case, you need to specify that
    branch:

    .. code-block:: sh

        VERSION=M.N.0 BRANCH=stable_M.N make start_branch

    This includes the following steps:

    * create the start branch (``start_M.N.U``), if it does not yet exist
    * create a dummy change
    * commit and push the start branch (``start_M.N.U``)

2.  On GitHub, create a milestone for the new version ``M.N.U``.

    You can create a milestone in GitHub via Issues -> Milestones -> New
    Milestone.

3.  On GitHub, create a Pull Request for branch ``start_M.N.U``.

    Important: When creating Pull Requests, GitHub by default targets the
    ``master`` branch. When starting a version based on a stable branch, you
    need to change the target branch of the Pull Request to ``stable_M.N``.

    No review is needed for this PR.

    Set the milestone of that PR to the new version ``M.N.U``.

4.  On GitHub, go through all open issues and pull requests that still have
    milestones for previous releases set, and either set them to the new
    milestone, or to have no milestone.

    Note that when the release process has been performed as described, there
    should not be any such issues or pull requests anymore. So this step here
    is just an additional safeguard.

5.  On GitHub, once the checks for the Pull Request for branch ``start_M.N.U``
    have succeeded, merge the Pull Request (no review is needed). This
    automatically deletes the branch on GitHub.

6.  Update and clean up the local repo (replace M,N,U accordingly):

    .. code-block:: sh

        VERSION=M.N.U make start_tag

    or (see step 1):

    .. code-block:: sh

        VERSION=M.N.0 BRANCH=stable_M.N make start_tag

    This includes the following steps:

    * checkout and pull the branch that was started (``master`` or ``stable_M.N``)
    * delete the start branch (``start_M.N.U``) locally and remotely
    * create and push the start tag (``M.N.Ua0``)
