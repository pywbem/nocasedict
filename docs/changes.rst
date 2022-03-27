
.. _`Change log`:

Change log
==========


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
