nocasedict - A case-insensitive ordered dictionary for Python
=============================================================

.. image:: https://badge.fury.io/py/nocasedict.svg
    :target: https://pypi.python.org/pypi/nocasedict/
    :alt: Version on Pypi

.. image:: https://github.com/pywbem/nocasedict/workflows/test/badge.svg?branch=master
    :target: https://github.com/pywbem/nocasedict/actions/
    :alt: Actions status

.. image:: https://readthedocs.org/projects/nocasedict/badge/?version=latest
    :target: https://readthedocs.org/projects/nocasedict/builds/
    :alt: Docs build status (master)

.. image:: https://coveralls.io/repos/github/pywbem/nocasedict/badge.svg?branch=master
    :target: https://coveralls.io/github/pywbem/nocasedict?branch=master
    :alt: Test coverage (master)


Overview
--------

Class `NocaseDict`_ is a case-insensitive ordered dictionary that preserves
the original lexical case of its keys.

Example:

.. code-block:: bash

    $ python
    >>> from nocasedict import NocaseDict

    >>> dict1 = NocaseDict({'Alpha': 1, 'Beta': 2})

    >>> dict1['ALPHA']  # Lookup by key is case-insensitive
    1

    >>> print(dict1)  # Keys are returned with the original lexical case
    NocaseDict({'Alpha': 1, 'Beta': 2})

The `NocaseDict`_ class supports the functionality of the built-in
`dict class of Python 3.8`_ on all Python versions it supports with
the following exceptions (and the case-insensitivity of course):

* The ``iter..()``, ``view..()`` and ``has_key()`` methods are only present
  on Python 2, consistent with the built-in ``dict`` class.

* The ``keys()``, ``values()`` and ``items()`` methods return a list on Python 2
  and a dictionary view on Python 3, consistent with the built-in ``dict``
  class.

.. _dict class of Python 3.8: https://docs.python.org/3.8/library/stdtypes.html#dict

Functionality can be added using mixin classes:

* `HashableMixin`_ mixin class: Adds case-insensitive hashability.

* `KeyableByMixin`_ mixin generator function: Adds ability to get the key from
  an attribute of the value object.

Why yet another case-insensitive dictionary: We found that all previously
existing case-insensitive dictionary packages on Pypi either had flaws, were
not well maintained, or did not support the Python versions we needed.

.. _dict of Python 2: https://docs.python.org/2/library/stdtypes.html#dict
.. _dict of Python 3: https://docs.python.org/3/library/stdtypes.html#dict
.. _NocaseDict: https://nocasedict.readthedocs.io/en/stable/reference.html#nocasedict.NocaseDict
.. _HashableMixin: https://nocasedict.readthedocs.io/en/stable/reference.html#nocasedict.HashableMixin
.. _KeyableByMixin: https://nocasedict.readthedocs.io/en/stable/reference.html#nocasedict.KeyableByMixin

Installation
------------

To install the latest released version of the nocasedict package into your
active Python environment:

.. code-block:: bash

    $ pip install nocasedict

This will also install any prerequisite Python packages.

For more details and alternative ways to install, see `Installation`_.

.. _Installation: https://nocasedict.readthedocs.io/en/stable/intro.html#installation


Documentation
-------------

* `Documentation <https://nocasedict.readthedocs.io/en/stable/>`_


Change History
--------------

* `Change history <https://nocasedict.readthedocs.io/en/stable/changes.html>`_


Contributing
------------

For information on how to contribute to the nocasedict project, see
`Contributing <https://nocasedict.readthedocs.io/en/stable/development.html#contributing>`_.


License
-------

The nocasedict project is provided under the
`GNU Lesser General Public License (LGPL) version 2.1 <https://raw.githubusercontent.com/pywbem/nocasedict/master/LICENSE>`_,
or (at your option) any later version.
