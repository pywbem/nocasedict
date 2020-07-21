nocasedict - A case-insensitive ordered dictionary for Python
=============================================================

.. image:: https://badge.fury.io/py/nocasedict.svg
    :target: https://pypi.python.org/pypi/nocasedict/
    :alt: Version on Pypi

.. image:: https://travis-ci.org/pywbem/nocasedict.svg?branch=master
    :target: https://travis-ci.org/github/pywbem/nocasedict/builds
    :alt: Travis test status (master)

.. image:: https://ci.appveyor.com/api/projects/status/d13osi3pxfduj4ap/branch/master?svg=true
    :target: https://ci.appveyor.com/project/andy-maier/nocasedict/history
    :alt: Appveyor test status (master)

.. image:: https://readthedocs.org/projects/nocasedict/badge/?version=latest
    :target: https://readthedocs.org/projects/nocasedict/builds/
    :alt: Docs build status (master)

.. image:: https://coveralls.io/repos/github/pywbem/nocasedict/badge.svg?branch=master
    :target: https://coveralls.io/github/pywbem/nocasedict?branch=master
    :alt: Test coverage (master)


Overview
--------

Class ``NocaseDict`` is a case-insensitive ordered dictionary that preserves
the lexical case of its keys.

Example:

.. code-block:: bash

    $ python
    >>> from nocasedict import NocaseDict

    >>> dict1 = NocaseDict({'Alpha': 1, 'Beta': 2})

    >>> dict1['ALPHA']  # Any lookup or comparison by key is case-insensitive
    1

    >>> print(dict1)  # Any access of keys is case-preserving
    NocaseDict({'Alpha': 1, 'Beta': 2})


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
