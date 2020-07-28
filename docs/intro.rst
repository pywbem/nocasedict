
.. _`Introduction`:

Introduction
============


.. _`Functionality`:

Functionality
-------------

Class :class:`nocasedict.NocaseDict` is a case-insensitive ordered dictionary
that preserves the original lexical case of its keys.

Example:

.. code-block:: bash

    $ python
    >>> from nocasedict import NocaseDict

    >>> dict1 = NocaseDict({'Alpha': 1, 'Beta': 2})

    >>> dict1['ALPHA']  # Lookup by key is case-insensitive
    1

    >>> print(dict1)  # Keys are returned with the original lexical case
    NocaseDict({'Alpha': 1, 'Beta': 2})

The :class:`~nocasedict.NocaseDict` class supports the functionality of the
built-in `dict class of Python 3.8`_ on all Python versions it supports, with
these exceptions (and the case-insensitivity of course):

* The ``iter..()``, ``view..()`` and ``has_key()`` methods are only present
  on Python 2, consistent with the built-in ``dict`` class.

* The ``keys()``, ``values()`` and ``items()`` methods return a list on Python 2
  and a dictionary view on Python 3, consistent with the built-in ``dict``
  class.

.. _dict class of Python 3.8: https://docs.python.org/3.8/library/stdtypes.html#dict

Functionality can be added using mixin classes:

* :class:`~nocasedict.HashableMixin` mixin class: Adds case-insensitive
  hashability.

* :func:`~nocasedict.KeyableByMixin` mixin generator function: Adds ability
  to get the key from an attribute of the value object.

Why yet another case-insensitive dictionary: We found that all previously
existing case-insensitive dictionary packages on Pypi either had flaws, were
not well maintained, or did not support the Python versions we needed.

.. _`Installation`:

Installation
------------


.. _`Supported environments`:

Supported environments
^^^^^^^^^^^^^^^^^^^^^^

The package does not have any dependencies on the type of operating system and
is regularly tested in CI systems on the following operating systems:

* Ubuntu, native Windows, CygWin, OS-X / macOS

The package is supported on the following Python versions:

* Python: 2.7, 3.4 and all higher 3.x versions


.. _`Installing`:

Installing
^^^^^^^^^^

* Prerequisites:

  - The Python environment into which you want to install must be the current
    Python environment, and must have at least the following Python packages
    installed:

    - setuptools
    - wheel
    - pip

* Install the nocasedict package and its prerequisite
  Python packages into the active Python environment:

  .. code-block:: bash

      $ pip install nocasedict


.. _`Installing a different version`:

Installing a different version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The examples in the previous sections install the latest version of
nocasedict that is released on `PyPI`_.
This section describes how different versions of nocasedict
can be installed.

* To install an older released version of nocasedict,
  Pip supports specifying a version requirement. The following example installs
  nocasedict version 0.1.0
  from PyPI:

  .. code-block:: bash

      $ pip install nocasedict==0.1.0

* If you need to get a certain new functionality or a new fix that is
  not yet part of a version released to PyPI, Pip supports installation from a
  Git repository. The following example installs nocasedict
  from the current code level in the master branch of the
  `nocasedict repository`_:

  .. code-block:: bash

      $ pip install git+https://github.com/pywbem/nocasedict.git@master#egg=nocasedict

.. _nocasedict repository: https://github.com/pywbem/nocasedict

.. _PyPI: https://pypi.python.org/pypi


.. _`Verifying the installation`:

Verifying the installation
^^^^^^^^^^^^^^^^^^^^^^^^^^

You can verify that nocasedict is installed correctly by
importing the package into Python (using the Python environment you installed
it to):

.. code-block:: bash

    $ python -c "import nocasedict; print('ok')"
    ok


.. _`Package version`:

Package version
---------------

The version of the nocasedict package can be accessed by
programs using the ``nocasedict.__version__`` variable:

.. autodata:: nocasedict._version.__version__

Note: For tooling reasons, the variable is shown as
``nocasedict._version.__version__``, but it should be used as
``nocasedict.__version__``.


.. _`Compatibility and deprecation policy`:

Compatibility and deprecation policy
------------------------------------

The nocasedict project uses the rules of
`Semantic Versioning 2.0.0`_ for compatibility between versions, and for
deprecations. The public interface that is subject to the semantic versioning
rules and specificically to its compatibility rules are the APIs and commands
described in this documentation.

.. _Semantic Versioning 2.0.0: https://semver.org/spec/v2.0.0.html

The semantic versioning rules require backwards compatibility for new minor
versions (the 'N' in version 'M.N.P') and for new patch versions (the 'P' in
version 'M.N.P').

Thus, a user of an API or command of the nocasedict project
can safely upgrade to a new minor or patch version of the
nocasedict package without encountering compatibility
issues for their code using the APIs or for their scripts using the commands.

In the rare case that exceptions from this rule are needed, they will be
documented in the :ref:`Change log`.

Occasionally functionality needs to be retired, because it is flawed and a
better but incompatible replacement has emerged. In the
nocasedict project, such changes are done by deprecating
existing functionality, without removing it immediately.

The deprecated functionality is still supported at least throughout new minor
or patch releases within the same major release. Eventually, a new major
release may break compatibility by removing deprecated functionality.

Any changes at the APIs or commands that do introduce
incompatibilities as defined above, are described in the :ref:`Change log`.

Deprecation of functionality at the APIs or commands is
communicated to the users in multiple ways:

* It is described in the documentation of the API or command

* It is mentioned in the change log.

* It is raised at runtime by issuing Python warnings of type
  ``DeprecationWarning`` (see the Python :mod:`py:warnings` module).

Since Python 2.7, ``DeprecationWarning`` messages are suppressed by default.
They can be shown for example in any of these ways:

* By specifying the Python command line option: ``-W default``
* By invoking Python with the environment variable: ``PYTHONWARNINGS=default``

It is recommended that users of the nocasedict project
run their test code with ``DeprecationWarning`` messages being shown, so they
become aware of any use of deprecated functionality.

Here is a summary of the deprecation and compatibility policy used by
the nocasedict project, by version type:

* New patch version (M.N.P -> M.N.P+1): No new deprecations; no new
  functionality; backwards compatible.
* New minor release (M.N.P -> M.N+1.0): New deprecations may be added;
  functionality may be extended; backwards compatible.
* New major release (M.N.P -> M+1.0.0): Deprecated functionality may get
  removed; functionality may be extended or changed; backwards compatibility
  may be broken.


.. _'Python namespaces`:

Python namespaces
-----------------

This documentation describes only the external APIs of the
nocasedict project, and omits any internal symbols and
any sub-modules.
