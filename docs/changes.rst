
.. _`Change log`:

Change log
==========


nocasedict 0.5.1.dev1
---------------------

Released: not yet

**Incompatible changes:**

**Deprecations:**

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

**Enhancements:**

**Cleanup:**

**Known issues:**

* See `list of open issues`_.

.. _`list of open issues`: https://github.com/pywbem/nocasedict/issues


nocasedict 0.5.0
----------------

Released: 2020-07-29

Initial release
