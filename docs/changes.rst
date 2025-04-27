
.. _`Change log`:

Change log
==========


nocasedict 2.1.0
----------------

Released: 2025-04-27

**Incompatible changes:**

* Dropped support for Python 3.6 and 3.7 because they are out of service and
  to simplify development dependencies. (issue #214)

* Dev: Changed 'make install' to no longer perform an editable install, but
  a standalone install, since pip will remove support for editable installs.
  (related to issue #180)

* Dev: Removed support for the env.var TEST_INSTALLED that used the installed
  package for testing, for simplicity. Now, the local package in the repository
  main directory is always used for testing.

* Test: Python 3.13 was pinned to 3.13.0 to work around a pylint issue on
  Python 3.13.1.

**Bug fixes:**

* Addressed safety issues up to 2025-04-27.

* Dev: Added missing dependencies for development.

* Test: Fixed the issue that coveralls was not found in the test workflow on MacOS
  with Python 3.9-3.11, by running it without login shell. Added Python 3.11 on
  MacOS to the normal tests.

**Enhancements:**

* Added support for Python 3.13. This required increasing the minimum version
  of several packages needed for development. (issue #225)

* Added '__version_tuple__' with the integer versions. (related to issue #180)

* Dev: Changed from setup.py to using pyproject.toml. (issue #180)

**Cleanup:**

* Dev: Split safety policy files into one for installation dependencies and one
  for development dependencies. (issue #205, related to issue #180)

* Dev: Split minimum-constraints.txt file into one for installation dependencies
  and one for development dependencies. (related to issue #180)

* Dev: Cleanup in the Makefile. (related to issue #180)

* Docs: Changed versions shown for the documentation to be master and the
  latest fix version of each minor version. Changed documentation links in
  README file to reference the master version.


nocasedict 2.0.4
----------------

Released: 2024-08-18

**Bug fixes:**

* Fixed safety issues up to 2024-08-18.

**Cleanup:**

* Test: Increased versions of GitHub Actions plugins used, to eliminate warnings
  about node v16.


nocasedict 2.0.3
----------------

Released: 2024-05-05

**Bug fixes:**

* Docs: Added Python 3.12 to the supported versions in the package metadata.
  (issue #196)

* Docs: Updated the README file with the changes from the introduction section
  w.r.t. Python 2 and limitations. (issue #195)


nocasedict 2.0.2
----------------

Released: 2024-05-05

**Incompatible changes:**

* Installation of this package using "setup.py" is no longer supported.
  Use "pip" instead.

**Bug fixes:**

* Dev: Fixed flake8 issue about comparing types in test code.

* Fixed safety issues up to 2024-05-05. No changes in package dependencies.

* Test: Removed setup.py based installs from "make installtest", since one
  of them started installing a pre-release of a package on an unsupported Python
  version. The recommendation has been for a while now to no longer use

* Docs: Added RTD config file .readthedocs.yaml

* Test: In the Github Actions test workflow for Python 3.6 and 3.7, changed
  macos-latest back to macos-12 because macos-latest got upgraded from macOS 12
  to macOS 14 which no longer supports these Python versions.

* Test: Fixed issues resulting from removal of support for pytest.warns(None)
  in pytest version 8.

* Docs: Converted README file from RST to MarkDown to fix badge alignment issue
  (issue #172)

* Dev: Added missing dependency to minimum-constraints.txt to several make
  targets that used it with PACKAGE_LEVEL=minimum.

**Enhancements:**

* Test: Added support for Python 3.12. (issue #178)

* Improvements for safety check tool: Made passing the safety check mandatory;
  Fixed safety issues; Separated the safety check into a separate make target;
  Added a safety policy file.

* Test: Moved the Safety run to the end of the test workflow because it regularly
  fails due to new issues introduced by other packages, in order to surface
  our own issues in the test runs in any case.

* Added support for a new make target 'authors' that generates an AUTHORS.md
  file from the git commit history. Added the invocation of 'make authors' to
  the description of how to release a version in the development
  documentation. (issue #173)

* Test: Added a step to the test workflow for displaying the tree of all
  package dependencies using pipdeptree. (issue #175)

* Dev: Optimized pip backtracking when installing devlopment packages.
  (issue #177)

* Test: Added a new make target 'check_reqs' that checks missing package
  dependencies, and added a step to the test workflow that runs it.
  (issue #176)

* Docs: In the Introduction section, documented the limitation that 'd | other'
  and 'd |= other' which were added to the standard Pyton 'dict' class in Python
  3.9 are not yet supported by nocasedict.

**Cleanup:**

* Dev: Removed description of stable branches in development.rst because this
  project maintains only the master branch. (issue #171)

* Converted percent-style and format() based string formatting to f-strings.
  (issue #174)

* Docs: In the Introduction section, removed statements about the nocasedict
  behavior in Python 2.


nocasedict 2.0.1
----------------

Released: 2023-05-01

**Bug fixes:**

* Fixed coveralls issues with KeyError and HTTP 422 Unprocessable Entity.


nocasedict 2.0.0
----------------

This version also contains all changes from 1.1.1.

Released: 2023-02-26

**Incompatible changes:**

* Removed support for Python 2.7, 3.4, 3.5. The minimum required Python version
  is now 3.6. This was needed in order to add Python type hints (issue #123).

**Bug fixes:**

* Enabled Github Actions for stable branches.

* Addressed new issues of Pylint 2.16.

**Enhancements:**

* Added type hints and type checking with MyPy (issue #123).

* Resurrected support for byte string keys that was removed in version 1.1.0.
  (issue #139)


nocasedict 1.1.0
----------------

Released: 2023-01-21

**Incompatible changes:**

* The default casefolding method on Python 3 was changed from `str.lower()`
  to `str.casefold()`. This changes the matching of the case-insensitive keys.
  This shold normally be an improvement, but in case you find that you are
  negatively affected by this change, you can go back to the `str.lower()`
  method by overriding the `NocaseDict.__casefold__()` method with a method
  that calls `str.lower()`. (issue #122)

**Enhancements:**

* Added support for Python 3.11.

* Changed the default casefolding method on Python 3 to be `str.casefold()`
  in order to improve Unicode support. On Python 2, it remains `str.lower()`.
  Added support for user-defined casefolding. (issue #122)


nocasedict 1.0.4
----------------

Released: 2022-08-04

**Bug fixes:**

* Various bug fixes in dependencies and test environment


nocasedict 1.0.3
----------------

Released: 2022-03-27

**Bug fixes:**

* Mitigated the coveralls HTTP status 422 by pinning coveralls-python to
  <3.0.0 (issue #55).

* Fixed issues raised by new Pylint 2.9 and 2.10.

* Fixed a dependency error that caused importlib-metadata to be installed on
  Python 3.8, while it is included in the Python base.

* Disabled new Pylint issue 'consider-using-f-string', since f-strings were
  introduced only in Python 3.6.

* Fixed install error of wrapt 1.13.0 on Python 2.7 on Windows due to lack of
  MS Visual C++ 9.0 on GitHub Actions, by pinning it to <1.13.

* Fixed potential issue with Sphinx/docutils versions on Python 2.7.

* Fixed error when installing virtualenv in install test on Python 2.7.

* Fixed that the added setup.py commands (test, leaktest, installtest) were not
  displayed. They are now displayed at verbosity level 1 (using '-v').

**Enhancements:**

* Enhanced test matrix on GitHub Actions to always include Python 2.7 and
  Python 3.4 on Ubuntu and Windows, and Python 2.7 and Python 3.5 on macOS.

* Support for Python 3.10: Added Python 3.10 in GitHub Actions tests, and in
  package metadata.

**Cleanup:**

* Removed old tools that were needed for travis and Appveyor but no longer
  on GitHub Actions: remove_duplicate_setuptools.py, retry.bat


nocasedict 1.0.2
----------------

Released: 2021-01-01

**Enhancements:**

* Migrated from Travis and Appveyor to GitHub Actions. This required changes
  in several areas including dependent packages used for testing and coverage.
  This did not cause any changes on dependent packages used for the
  installation of the package.


nocasedict 1.0.1
----------------

Released: 2020-10-04

**Bug fixes:**

* Test: Fixed issue with virtualenv raising AttributeError during installtest
  on Python 3.4. (see issue #61)

* Fixed UserWarning about unpreserved order of input items. (see issue #59)

**Enhancements:**

* Added checking for no expected warning. Adjusted a testcase to accomodate
  the new check. (see issue #65)


nocasedict 1.0.0
----------------

Released: 2020-09-11

**Bug fixes:**

* Test: Fixed that the reversed test against the built-in dict was attempted
  on Python 3.7, but the built-in dict became reversible only in Python 3.8.
  (See issue #49)

* Test: Fixed issue on pypy2 (Python 2.7) where the testcases for update()
  passed keyword arguments that had integer-typed argument names. That is
  supported by CPython 2.7 when passing them as a kwargs dict, but not by
  pypy2. Removed these testcases, because the support for that feature in
  CPython 2.7 is not part of the Python language.

* Docs: Fixed missing Python 2 only methods in RTD docs (See issue #52)

* Pylint: Accomodated new 'raise-missing-from' check in Pylint 2.6.0.


nocasedict 0.5.0
----------------

Released: 2020-07-29

Initial release
