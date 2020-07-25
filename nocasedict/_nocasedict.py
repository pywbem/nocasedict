#
# (C) Copyright 2003-2007 Hewlett-Packard Development Company, L.P.
# (C) Copyright 2006-2007 Novell, Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# Original authors, until 2007:
#   Tim Potter <tpot@hp.com>
#   Martin Pool <mbp@hp.com>
#   Bart Whiteley <bwhiteley@suse.de>
#
# Authors since 2014:
#   Andreas Maier <andreas.r.maier@gmx.de>
#   Karl Schopmeyer <k.schopmeyer@swbell.net>
#

"""
The only class exposed by this package is :class:`nocasedict.NocaseDict`.
"""

from __future__ import print_function, absolute_import

import sys
import os
import warnings
from collections import OrderedDict
try:
    from collections.abc import MutableMapping, KeysView, ValuesView, ItemsView
except ImportError:
    from collections import MutableMapping, KeysView, ValuesView, ItemsView

import six

# Starting with Python 3.7, the standard dict is guaranteed to be ordered.
# Note: In CPython, that already happened in 3.6, but it was not guaranteed
# for all implementations.
# pylint: disable=invalid-name
ODict = dict if sys.version_info[0:2] >= (3, 7) else OrderedDict

DOCS_SHOW_ALL = os.getenv('DOCS_SHOW_ALL')

__all__ = ['NocaseDict']

# Used as default value for parameters to detect that they have not been
# specified as an argument. Idea from CPython's datetime.timezone.
_OMITTED = object()


def _real_key(key):
    """
    Return a case-insensitive form of the input key, or `None` if the input key
    is `None`.

    The input key object must have a ``lower()`` method (e.g. be a string)
    or be `None`.
    """
    if key is not None:
        try:
            return key.lower()
        except AttributeError:
            type_error = TypeError(
                "NocaseDict key {0!r} of type {1} does not have a lower() "
                "method".format(key, type(key)))
            type_error.__cause__ = None  # Suppress 'During handling..'
            raise type_error
    return None


class _DictView(object):
    # pylint: disable=too-few-public-methods
    """
    Base class for directory views, with common methods.
    """

    def __init__(self, dct):
        self._dict = dct

    def __len__(self):
        return len(self._dict)

    def __contains__(self, x):
        return x in iter(self)

    def __reversed__(self):
        return reversed(list(iter(self)))

    def __repr__(self):
        return "{t}({d!r})".format(
            t=self.__class__.__name__, d=self._dict)


class dict_keys(_DictView, KeysView):
    # pylint: disable=too-few-public-methods
    """
    Dictionary values view.
    """

    def __iter__(self):
        # pylint: disable=protected-access
        data = self._dict._data
        for k in data:
            yield data[k][0]


class dict_values(_DictView, ValuesView):
    # pylint: disable=too-few-public-methods
    """
    Dictionary values view.
    """

    def __iter__(self):
        # pylint: disable=protected-access
        data = self._dict._data
        for k in data:
            yield data[k][1]


class dict_items(_DictView, ItemsView):
    # pylint: disable=too-few-public-methods
    """
    Dictionary items view.
    """

    def __iter__(self):
        # pylint: disable=protected-access
        data = self._dict._data
        for k in data:
            yield data[k]


class NocaseDict(MutableMapping):
    # pylint: disable=line-too-long
    """
    A case-insensitive, ordered, and case-preserving, dictionary.

    The dictionary is case-insensitive: Whenever items of the dictionary are
    looked up by key or key values are compared, that is done
    case-insensitively. The case-insensitivity is defined by performing the
    lookup or comparison on the result of the ``lower()`` method on the key
    value. Therefore, objects used as keys must support the ``lower()`` method.
    If a key object does not do that, :exc:`py:TypeError` is raised.

    The dictionary is ordered: The dictionary maintains the order in which items
    were added for all Python versions supported by this package. This is
    consistent with the ordering behavior of the built-in :class:`py:dict`
    class starting with Python 3.7.

    The dictionary is case-preserving: Whenever key values are returned, they
    have the lexical case that was originally specified when adding or updating
    the item.

    The :class:`~nocasedict.NocaseDict` class is derived from the abstract base
    class :class:`py:MutableMapping`, and not from the :class:`py:dict` class.
    Reason is the unique implementation of :class:`~nocasedict.NocaseDict`,
    which maintains a single dictionary with the lower-cased keys, and values
    that are a tuple (original key, value). This supports key based lookup
    with a single dictionary lookup.
    Users that need to test whether an object is a dictionary should do that
    with `isinstance(obj, Mapping)` or  `isinstance(obj, MutableMapping)`

    Except for the case-insensitivity of its keys, the
    :class:`~nocasedict.NocaseDict` class behaves like the built-in
    :class:`py:dict` class starting with Python 3.7 (where it is guaranteed to
    be ordered), so its documentation applies completely.

    The provided key and value objects are not copied when they are added to
    the new dictionary, i.e. the dictionary will reference the provided
    objects.

    The following documentation is provided only for explicit documentation of
    the case-insensitive and ordering behavior.
    """  # noqa E401
    # pylint: enable=line-too-long

    # Methods not implemented:
    #
    # * __getattribute__(self, name): The method inherited from object is used;
    #   no reason to have a different implementation.
    #
    # * __sizeof__(self): The method inherited from object is used; no reason
    #   to have a different implementation.

    def __init__(self, *args, **kwargs):
        """
        Parameters:

          *args : An optional single positional argument that is used to
            initialize the dictionary in iteration order of the specified
            object. The argument must be one of:

            - a dictionary object, or more generally an object that supports
              subscription by key and has a method ``keys()`` returning an
              iterable of keys.

            - an iterable. If a key occurs more than once (case-insensitively),
              the last value for that key becomes the corresponding value in
              the dictionary. Each item in the iterable must be one of:

              * an iterable with exactly two items. The first item is used as
                the key, and the second item as the value.

              * If the :func:`~nocasedict.KeyableBy` mixin is used, an object
                with a key attribute named as specified in its ``key_attr``
                argument. The value of the key attribute is used as the key,
                and the object itself as the value.

          **kwargs : Optional keyword arguments representing key-value pairs to
            add to the dictionary initialized from the positional argument.

            Starting with Python 3.7, the order of keyword arguments
            as specified by the caller is preserved in the new dictionary.

            If a key being added is already present (case-insensitively) from
            the positional argument, the value from the keyword argument
            replaces the value from the positional argument.

        To summarize, only the following types of init arguments allow defining
        the order of items in the new dictionary across all Python versions
        supported by this package: Passing an iterable or an ordered mapping
        as a single positional argument, and passing at most one keyword
        argument. A :exc:`py:UserWarning` will be issued if the provided
        arguments cause the order of provided items not to be preserved.

        Raises:
          TypeError: Key does not have a ``lower()`` method.
          TypeError: Expected at most 1 positional argument, got {n}.
          ValueError: Cannot unpack positional argument item #{i}.
        """

        # The internal dictionary, with lower case keys. An item in this dict
        # is the tuple (original key, value).
        self._data = ODict()

        self.update(*args, **kwargs)

    # Basic accessor and setter methods

    def __getitem__(self, key):
        """
        Return the value of the item with an existing key (looked up
        case-insensitively).

        Invoked when using e.g.: ``value = ncd[key]``

        Raises:
          TypeError: Key does not have a ``lower()`` method.
          KeyError: Key does not exist (case-insensitively).
        """
        k = _real_key(key)
        try:
            return self._data[k][1]
        except KeyError:
            key_error = KeyError("Key {0!r} not found".format(key))
            key_error.__cause__ = None  # Suppress 'During handling..'
            raise key_error

    def __setitem__(self, key, value):
        """
        Update the value of the item with an existing key (looked up
        case-insensitively), or if an item with the key does not exist, add an
        item with the specified key and value.

        Invoked when using e.g.: ``ncd[key] = value``

        Raises:
          TypeError: Key does not have a ``lower()`` method.
        """
        k = _real_key(key)
        self._data[k] = (key, value)

    def __delitem__(self, key):
        """
        Delete the item with an existing key (looked up case-insensitively).

        Invoked when using: ``del ncd[key]``

        Raises:
          TypeError: Key does not have a ``lower()`` method.
          KeyError: Key does not exist (case-insensitively).
        """
        k = _real_key(key)
        try:
            del self._data[k]
        except KeyError:
            key_error = KeyError("Key {0!r} not found".format(key))
            key_error.__cause__ = None  # Suppress 'During handling..'
            raise key_error

    def __len__(self):
        """
        Return the number of items in the dictionary.

        Invoked when using: ``len(ncd)``
        """
        return len(self._data)

    def __contains__(self, key):
        """
        Return a boolean indicating whether the dictionary contains an item
        with the key (looked up case-insensitively).

        Invoked when using: ``key in ncd``

        Raises:
          TypeError: Key does not have a ``lower()`` method.
        """
        k = _real_key(key)
        return k in self._data

    def __reversed__(self):
        """
        Return an iterator for the reversed iteration order of the dictionary.
        """
        # Implementing __reversed__() is necessary because the fall back of
        # reversed() to using len() and __getitem__() (the sequence protocol")
        # requires that the object is a sequence, and relying on the fallback
        # for dicts results in TypeError.
        return reversed(self.keys())

    @classmethod
    def fromkeys(cls, iterable, value=None):
        """
        Return a new NocaseDict object with keys from the specified iterable
        of key values, and values all set to value.

        Raises:
          TypeError: Key does not have a ``lower()`` method.
        """
        return cls([(key, value) for key in iterable])

    def get(self, key, default=None):
        """
        Return the value of the item with an existing key (looked up
        case-insensitively), or if the key does not exist, a default value.

        Raises:
          TypeError: Key does not have a ``lower()`` method.
        """
        try:
            return self[key]
        except KeyError:
            return default

    def has_key(self, key):
        """
        Python 2 only: Return a boolean indicating whether the dictionary
        contains an item with the key (looked up case-insensitively).

        This method is only present on Python 2.

        Raises:
          TypeError: Key does not have a ``lower()`` method.
        """
        return key in self  # delegates to __contains__()

    def pop(self, key, default=_OMITTED):
        """
        Remove the item with the specified key if it exists (looked up
        case-insensitively), and return its value.

        If an item with the key does not exist, the default value is returned
        if specified, otherwise KeyError is raised.

        Raises:
          KeyError: Key does not exist (case-insensitively) and no default was
            specified.
        """
        k = _real_key(key)
        try:
            return self._data.pop(k)[1]
        except KeyError:
            if default is not _OMITTED:
                return default
            raise

    def popitem(self):
        """
        Remove the last dictionary item (in iteration order) and return it as a
        tuple (key, value).

        The last item in iteration order is the last item that was added to the
        dictionary.

        Raises:
          KeyError: Dictionary is empty.
        """
        return self._data.popitem()[1]

    def setdefault(self, key, default=None):
        """
        If an item with the key (looked up case-insensitively) does not exist,
        add an item with that key and the specified default value, and return
        the value of the item with the key.

        Raises:
          TypeError: Key does not have a ``lower()`` method.
        """
        if key not in self:
            self[key] = default
        return self[key]

    # Iteration methods

    def keys(self):
        # pylint: disable=line-too-long
        """
        Return a view on (in Python 3) or a list of (in Python 2) the
        dictionary keys (in the original lexical case) in the preserved order.

        See
        `Dictionary View Objects on Python 3 <https://docs.python.org/3/library/stdtypes.html#dictionary-view-objects>`_ for details about view objects.
        """  # noqa: E501
        # pylint: enable=line-too-long
        if six.PY2:
            return [self._data[k][0] for k in self._data]
        return dict_keys(self)

    def keys_nocase(self):
        # pylint: disable=line-too-long
        """
        Return a view on (in Python 3) or a list of (in Python 2) the
        lower-cased dictionary keys in the preserved order.

        See
        `Dictionary View Objects on Python 3 <https://docs.python.org/3/library/stdtypes.html#dictionary-view-objects>`_ for details about view objects.
        """  # noqa: E501
        # pylint: enable=line-too-long
        return self._data.keys()

    def values(self):
        # pylint: disable=line-too-long
        """
        Return a view on (in Python 3) or a list of (in Python 2) the
        dictionary values in the preserved order.

        See
        `Dictionary View Objects on Python 3 <https://docs.python.org/3/library/stdtypes.html#dictionary-view-objects>`_ for details about view objects.
        """  # noqa: E501
        # pylint: enable=line-too-long
        if six.PY2:
            return [self._data[k][1] for k in self._data]
        return dict_values(self)

    def items(self):
        # pylint: disable=line-too-long
        """
        Return a view on (in Python 3) or a list of (in Python 2) the
        dictionary items in the preserved order, where each item is a tuple of
        its key (in the original lexical case) and its value.

        See
        `Dictionary View Objects on Python 3 <https://docs.python.org/3/library/stdtypes.html#dictionary-view-objects>`_ for details about view objects.
        """  # noqa: E501
        # pylint: enable=line-too-long
        if six.PY2:
            return [self._data[k] for k in self._data]
        return dict_items(self)

    def iterkeys(self):
        """
        Python 2 only: Return an iterator through the dictionary keys (in the
        original lexical case) in the preserved order.

        This method is only present on Python 2.
        """
        for k in self._data:
            yield self._data[k][0]

    def itervalues(self):
        """
        Python 2 only: Return an iterator through the dictionary values in the
        preserved order.

        This method is only present on Python 2.
        """
        for k in self._data:
            yield self._data[k][1]

    def iteritems(self):
        """
        Python 2 only: Return an iterator through the dictionary items in the
        preserved order, where each item is a tuple of its key (in the original
        lexical case) and its value.

        This method is only present on Python 2.
        """
        for k in self._data:
            yield self._data[k]

    def viewkeys(self):
        # pylint: disable=line-too-long
        """
        Python 2 only: Return a view on the dictionary keys (in the original
        lexical case) in the preserved order.

        See
        `Dictionary View Objects on Python 2 <https://docs.python.org/2/library/stdtypes.html#dictionary-view-objects>`_ for details about view objects.

        This method is only present on Python 2.
        """  # noqa: E501
        # pylint: enable=line-too-long
        return dict_keys(self)

    def viewvalues(self):
        # pylint: disable=line-too-long
        """
        Python 2 only: Return a view on the dictionary values in the preserved
        order.

        See
        `Dictionary View Objects on Python 2 <https://docs.python.org/2/library/stdtypes.html#dictionary-view-objects>`_ for details about view objects.

        This method is only present on Python 2.
        """  # noqa: E501
        # pylint: enable=line-too-long
        return dict_values(self)

    def viewitems(self):
        # pylint: disable=line-too-long
        """
        Python 2 only: Return a view on the dictionary items in the preserved
        order, where each item is a tuple of its key (in the original lexical
        case) and its value.

        See
        `Dictionary View Objects on Python 2 <https://docs.python.org/2/library/stdtypes.html#dictionary-view-objects>`_ for details about view objects.

        This method is only present on Python 2.
        """  # noqa: E501
        # pylint: enable=line-too-long
        return dict_items(self)

    def __iter__(self):
        """
        Return an iterator through the dictionary keys (in the original lexical
        case) in the preserved order.

        Invoked when using: ``for key in ncd``
        """
        for k in self._data:
            yield self._data[k][0]

    # Other stuff

    def __repr__(self):
        """
        Return a string representation of the dictionary that is suitable for
        debugging.

        The order of dictionary items is the preserved order, and the keys are
        in the original lexical case.
        """
        items = ["{0!r}: {1!r}".format(key, value)
                 for key, value in six.iteritems(self)]
        items_str = ', '.join(items)
        return "{0.__class__.__name__}({{{1}}})".format(self, items_str)

    def update(self, *args, **kwargs):
        # pylint: disable=arguments-differ,signature-differs
        # Note: The signature in Python 3 is: update(self, other=(), /, **kwds)
        #       Since the / marker cannot be used in Python 2, the *args
        #       approach has the same effect, i.e. to ensure that the
        #       parameter can only be specified as a keyword argument.
        """
        Update the dictionary from key/value pairs.

        If an item for a key exists in the dictionary (looked up
        case-insensitively), its value is updated. If an item for a key does
        not exist, it is added to the dictionary.

        The provided key and value objects will be referenced from the
        dictionary without being copied.

        Parameters:

          *args : An optional single positional argument that must be one of:

            - a dictionary object, or more generally an object that supports
              subscription by key and has a method ``keys()`` returning an
              iterable of keys.

            - an iterable. If a key occurs more than once (case-insensitively),
              the last value for that key becomes the corresponding value in
              the dictionary. Each item in the iterable must be one of:

              * an iterable with exactly two items. The first item is used as
                the key, and the second item as the value.

              * If the :func:`~nocasedict.KeyableBy` mixin is used, an object
                with a key attribute named as specified in its ``key_attr``
                argument. The value of the key attribute is used as the key,
                and the object itself as the value.

          **kwargs : Optional keyword arguments representing key-value pairs to
            add to the dictionary.

            Starting with Python 3.7, the order of keyword arguments as
            specified by the caller is preserved.

            If a key being added is already present (case-insensitively) from
            the positional argument, the value from the keyword argument
            replaces the value from the positional argument.

        Raises:
          TypeError: Key does not have a ``lower()`` method.
          TypeError: Expected at most 1 positional argument, got {n}.
          ValueError: Cannot unpack positional argument item #{i}.
        """
        if args:
            if len(args) > 1:
                raise TypeError(
                    "Expected at most 1 positional argument, got {n}".
                    format(n=len(args)))
            other = args[0]
            try:
                # Try mapping / dictionary
                for key in other.keys():
                    self[key] = other[key]
                # pylint: disable=unidiomatic-typecheck
                if type(other) is dict and ODict is not dict:
                    warnings.warn(
                        "Before Python 3.7, initializing or updating a "
                        "NocaseDict object from a dict object is not "
                        "guaranteed to preserve the order of its items",
                        UserWarning, stacklevel=2)
            except AttributeError:
                # Expecting an iterable
                try:
                    # Try whether KeyableBy() mixin was used
                    key_attr = self.nocasedict_KeyableBy_key_attr
                except AttributeError:
                    key_attr = None
                # The following raises TypeError if not iterable:
                for i, item in enumerate(other):
                    if key_attr and hasattr(item, key_attr):
                        # Is a keyable object
                        key = getattr(item, key_attr)
                        value = item
                    else:
                        # Expecting key, value pair
                        try:
                            key, value = item
                        except ValueError as exc:
                            value_error = ValueError(
                                "Cannot unpack positional argument item #{i} "
                                "of type {t} into key, value: {exc}".
                                format(i=i, t=type(item), exc=exc))
                            value_error.__cause__ = None  # Suppress 'During..'
                            raise value_error
                    self[key] = value

        for key in kwargs:
            self[key] = kwargs[key]
        if len(kwargs) > 1 and ODict is not dict:
            warnings.warn(
                "Before Python 3.7, initializing or updating a NocaseDict "
                "object from more than one keyword argument is not guaranteed "
                "to preserve their order",
                UserWarning, stacklevel=2)

    def clear(self):
        """
        Remove all items from the dictionary.
        """
        self._data.clear()

    def copy(self):
        """
        Return a copy of the dictionary.

        This is a middle-deep copy; the copy is independent of the original in
        all attributes that have mutable types except for:

        * The values in the dictionary

        Note that the Python functions :func:`py:copy.copy` and
        :func:`py:copy.deepcopy` can be used to create completely shallow or
        completely deep copies of objects of this class.
        """
        result = NocaseDict()
        result._data = self._data.copy()  # pylint: disable=protected-access
        return result

    def __eq__(self, other):
        """
        Return a boolean indicating whether the dictionary and the other
        dictionary are equal, by matching items (case-insensitively) based on
        their keys, and then comparing the values of matching items for
        equality.

        The other dictionary may be a :class:`NocaseDict` object or any other
        mapping. In all cases, the matching of keys takes place
        case-insensitively.

        Invoked when using e.g.: ``ncd == other``

        Raises:
          TypeError: Key does not have a ``lower()`` method.
        """
        # Issue #1062: Could compare hash values for better performance
        for key, self_value in six.iteritems(self):
            if key not in other:
                return False
            other_value = other[key]
            try:
                if not self_value == other_value:
                    return False
            except TypeError:
                return False  # not comparable -> considered not equal
        return len(self) == len(other)

    def __ne__(self, other):
        """
        Return a boolean indicating whether the dictionary and the other
        dictionary are not equal, by negating the equality test.

        The other dictionary may be a :class:`NocaseDict` object or any other
        mapping. In all cases, the matching of keys takes place
        case-insensitively.

        Invoked when using e.g.: ``ncd != other``

        Raises:
          TypeError: Key does not have a ``lower()`` method.
        """
        return not self == other

    def _raise_ordering_not_supported(self, other, op):
        """
        Function to raise a TypeError indicating that ordering of this class
        is not supported.
        """
        raise TypeError(
            "'{}' not supported between instances of '{}' and '{}'".
            format(op, type(self), type(other)))

    def __lt__(self, other):
        self._raise_ordering_not_supported(other, '<')

    def __gt__(self, other):
        self._raise_ordering_not_supported(other, '>')

    def __ge__(self, other):
        self._raise_ordering_not_supported(other, '>=')

    def __le__(self, other):
        self._raise_ordering_not_supported(other, '<=')


# Remove methods that should only be present in a particular Python version
if sys.version_info[0] != 2 and not DOCS_SHOW_ALL:
    del NocaseDict.has_key
    del NocaseDict.iterkeys
    del NocaseDict.itervalues
    del NocaseDict.iteritems
    del NocaseDict.viewkeys
    del NocaseDict.viewvalues
    del NocaseDict.viewitems
