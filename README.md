# nocasedict - A case-insensitive ordered dictionary for Python

[![Version on Pypi](https://img.shields.io/pypi/v/nocasedict.svg)](https://pypi.python.org/pypi/nocasedict/)
[![Test status (master)](https://github.com/pywbem/nocasedict/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/pywbem/nocasedict/actions/workflows/test.yml?query=branch%3Amaster)
[![Docs status (master)](https://readthedocs.org/projects/nocasedict/badge/?version=master)](https://readthedocs.org/projects/nocasedict/builds/)
[![Test coverage (master)](https://coveralls.io/repos/github/pywbem/nocasedict/badge.svg?branch=master)](https://coveralls.io/github/pywbem/nocasedict?branch=master)

# Overview

Class
[NocaseDict](https://nocasedict.readthedocs.io/en/master/reference.html#nocasedict.NocaseDict)
is a case-insensitive ordered dictionary that preserves the original
lexical case of its keys.

Example:

    $ python
    >>> from nocasedict import NocaseDict

    >>> dict1 = NocaseDict({'Alpha': 1, 'Beta': 2})

    >>> dict1['ALPHA']  # Lookup by key is case-insensitive
    1

    >>> print(dict1)  # Keys are returned with the original lexical case
    NocaseDict({'Alpha': 1, 'Beta': 2})

The
[NocaseDict](https://nocasedict.readthedocs.io/en/master/reference.html#nocasedict.NocaseDict)
class supports the functionality of the built-in
[dict class of Python 3.8](https://docs.python.org/3.8/library/stdtypes.html#dict)
on all Python versions it supports.

Limitation: Any functionalities added to the `dict` class in Python 3.9 or
later are not yet supported. These are:

* `d | other` - Added in Python 3.9.
* `d |= other` - Added in Python 3.9.

The case-insensitivity is achieved by matching any key values as their
casefolded values. By default, the casefolding is performed with
[str.casefold()](https://docs.python.org/3/library/stdtypes.html#str.casefold)
for unicode string keys and with
[bytes.lower()](https://docs.python.org/3/library/stdtypes.html#bytes.lower)
for byte string keys. The default casefolding can be overridden with a
user-defined casefold method.

Functionality can be added using mixin classes:

- [HashableMixin](https://nocasedict.readthedocs.io/en/master/reference.html#nocasedict.HashableMixin)
  mixin class: Adds case-insensitive hashability.
- [KeyableByMixin](https://nocasedict.readthedocs.io/en/master/reference.html#nocasedict.KeyableByMixin)
  mixin generator function: Adds ability to get the key from an
  attribute of the value object.

Why yet another case-insensitive dictionary: We found that all
previously existing case-insensitive dictionary packages on Pypi either
had flaws, were not well maintained, or did not support the Python
versions we needed.

# Installation

To install the latest released version of the nocasedict package into
your active Python environment:

    $ pip install nocasedict

This will also install any prerequisite Python packages.

For more details and alternative ways to install, see
[Installation](https://nocasedict.readthedocs.io/en/master/intro.html#installation).

# Documentation

- [Documentation](https://nocasedict.readthedocs.io/en/master/)

# Change History

- [Change history](https://nocasedict.readthedocs.io/en/master/changes.html)

# Contributing

For information on how to contribute to the nocasedict project, see
[Contributing](https://nocasedict.readthedocs.io/en/master/development.html#contributing).

# License

The nocasedict project is provided under the
[GNU Lesser General Public License (LGPL) version 2.1](https://raw.githubusercontent.com/pywbem/nocasedict/master/LICENSE),
or (at your option) any later version.
