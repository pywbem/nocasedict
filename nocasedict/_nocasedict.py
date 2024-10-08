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


import os
from collections.abc import MutableMapping, KeysView, ValuesView, ItemsView
from typing import Any, AnyStr, NoReturn, Optional, Iterator, Tuple, Dict

__all__ = ['NocaseDict']

# Note: Since the minimum version for nocasedict is Python 3.8, the standard
# dict is guaranteed to be ordered and the implementation uses dict when an
# ordered dict is needed.

Key = Optional[AnyStr]

# This env var is set when building the docs. It causes the methods
# that are supposed to exist only in a particular Python version, not to be
# removed, so they appear in the docs.
BUILDING_DOCS = os.environ.get('BUILDING_DOCS', False)

# Used as default value for parameters to detect that they have not been
# specified as an argument. Idea from CPython's datetime.timezone.
_OMITTED = object()


class _DictView:
    # pylint: disable=too-few-public-methods
    """
    Base class for directory views, with common methods.
    """

    def __init__(self, dct):
        self._dict = dct

    def __len__(self):
        return len(self._dict)

    def __contains__(self, x):
        # pylint: disable=invalid-name
        return x in iter(self)

    def __reversed__(self):
        return reversed(list(iter(self)))

    def __repr__(self):
        return f"{self.__class__.__name__}({self._dict!r})"


class dict_keys(_DictView, KeysView):
    # pylint: disable=too-few-public-methods,invalid-name
    """
    Dictionary values view.
    """

    def __iter__(self):
        # pylint: disable=protected-access
        data = self._dict._data
        for k in data:
            yield data[k][0]


class dict_values(_DictView, ValuesView):
    # pylint: disable=too-few-public-methods,invalid-name
    """
    Dictionary values view.
    """

    def __iter__(self):
        # pylint: disable=protected-access
        data = self._dict._data
        for k in data:
            yield data[k][1]


class dict_items(_DictView, ItemsView):
    # pylint: disable=too-few-public-methods,invalid-name
    """
    Dictionary items view.
    """

    def __iter__(self):
        # pylint: disable=protected-access
        data = self._dict._data
        for k in data:
            yield data[k]


class NocaseDict(MutableMapping):
    """
    A case-insensitive and case-preserving ordered dictionary.

    The dictionary is case-insensitive: When items of the dictionary are
    looked up by key or keys are compared by the dictionary, that is done
    case-insensitively. The case-insensitivity is defined by performing the
    lookup or comparison on the result of the :meth:`__casefold__` method on
    the key value.
    `None` is allowed as a key value and will not be case folded.

    The dictionary is case-preserving: When keys are returned, they have
    the lexical case that was originally specified when adding or updating the
    item.

    The dictionary is ordered: The dictionary maintains the order in which items
    were added for all Python versions supported by this package. This is
    consistent with the ordering behavior of the built-in :class:`py:dict`
    class starting with Python 3.7.

    The :class:`~nocasedict.NocaseDict` class is derived from the abstract base
    class :class:`py:collections.abc.MutableMapping` and not from the
    :class:`py:dict` class, because of the unique implementation of
    :class:`~nocasedict.NocaseDict`, which maintains a single dictionary with
    the casefolded keys, and values that are tuples (original key, value).
    This supports key based lookup with a single dictionary lookup.
    Users that need to test whether an object is a dictionary should do that
    with ``isinstance(obj, Mapping)`` or ``isinstance(obj, MutableMapping)``.

    The provided key and value objects will be referenced from the
    dictionary without being copied, consistent with the built-in
    :class:`py:dict` class.

    Except for the case-insensitivity of its keys, the
    :class:`~nocasedict.NocaseDict` class behaves like the built-in
    :class:`py:dict` class starting with Python 3.7 (where it is guaranteed to
    be ordered), so its documentation applies completely.

    The :class:`~nocasedict.NocaseDict` class itself provides no added
    functionality compared to the built-in :class:`py:dict` class.
    This package provides mixin classes for adding functionality:

    * :class:`~nocasedict.HashableMixin` mixin class: Adds case-insensitive
      hashability.

    * :func:`~nocasedict.KeyableByMixin` mixin generator function: Adds ability
      to get the key from an attribute of the value object.

    Example of usage::

        from nocasedict import NocaseDict

        dict1 = NocaseDict({'Alpha': 1, 'Beta': 2})

        print(dict1['ALPHA'])  # Lookup by key is case-insensitive
        # 1

        print(dict1)  # Access of keys is case-preserving
        # NocaseDict({'Alpha': 1, 'Beta': 2})
    """

    # Methods not implemented:
    #
    # * __getattribute__(self, name): The method inherited from object is used;
    #   no reason to have a different implementation.
    #
    # * __sizeof__(self): The method inherited from object is used.
    #   TODO(issue #37): Clarify the rules for implementing __sizeof__().

    def __init__(self, *args, **kwargs) -> None:
        """
        Parameters:

          *args : An optional single positional argument representing key-value
            pairs to initialize the dictionary from, in iteration order of the
            specified object. The argument must be one of:

            - a dictionary object, or more specifically an object that has a
              method ``keys()`` providing iteration through the keys and that
              supports subscription by key (e.g. ``ncd[key]``) for accessing
              the values.

            - an iterable. If a key occurs more than once (case-insensitively),
              the last item for that key becomes the corresponding item in
              the dictionary. Each item in the iterable must be one of:

              * an iterable with exactly two items. The first item is used as
                the key, and the second item as the value.

              * an object with a key attribute, if the
                :func:`~nocasedict.KeyableByMixin` mixin generator function is
                used. The value of the key attribute is used as the key, and
                the object itself as the value.

          **kwargs : Optional keyword arguments representing key-value pairs to
            add to the dictionary after being initialized from the positional
            argument.

            If a key being added is already present (case-insensitively) from
            the positional argument, key and value will be updated from the
            keyword argument.

            Before Python 3.7, the order of keyword arguments as specified in
            the call to the method was not guaranteed to be preserved for the
            method implementation, so passing more than one keyword argument
            may have resulted in arbitrary order of items in the dictionary.

        To summarize, only the following types of init arguments are guaranteed
        to preserve the order of provided items after having been added to the
        new dictionary, across all Python versions supported by this package:

        * Passing an iterable as a single positional argument, and passing at
          most one keyword argument.

        * Passing an ordered dictionary/mapping as a single positional
          argument, and passing at most one keyword argument.

        A :exc:`py:UserWarning` will be issued if the order of provided items
        in the arguments is not guaranteed to be preserved.

        Examples for initializing::

            from nocasedict import NocaseDict

            dict1 = NocaseDict({'Alpha': 1, 'Beta': 2})
            dict2 = NocaseDict(dict1)
            dict3 = NocaseDict([('Alpha', 1), ('Beta', 2)])
            dict4 = NocaseDict((('Alpha', 1), ('Beta', 2)))
            dict5 = NocaseDict(Alpha=1, Beta=2)
            dict6 = NocaseDict(dict1, BETA=3)

        Raises:
          TypeError: Expected at most 1 positional argument, got {n}.
          ValueError: Cannot unpack positional argument item #{i}.
        """

        # The internal dictionary, with casefolded keys. An item in this dict
        # is the tuple (original key, value).
        self._data: Dict[Key, Any] = {}

        self.update(*args, **kwargs)

    def _casefolded_key(self, key: Key) -> Key:
        """
        This method returns the casefolded key and handles the case of key
        being `None`.
        """
        if key is None:
            return None
        return self.__casefold__(key)

    @staticmethod
    def __casefold__(key: AnyStr) -> AnyStr:
        """
        This method implements the case-insensitive behavior of the class.

        It returns a case-insensitive form of the input key by calling a
        "casefold method" on the key. The input key will not be `None`.

        The casefold method called by this method is :meth:`py:str.casefold`.
        If that method does not exist on the key value (e.g. because it is a
        byte string), :meth:`py:bytes.lower` is called, for compatibility with
        earlier versions of the package.

        This method can be overridden by users in order to change the
        case-insensitive behavior of the class.
        See :ref:`Overriding the default casefold method` for details.

        Parameters:
            key (AnyStr): Input key. Will not be `None`.

        Returns:
            AnyStr: Case-insensitive form of the input key.

        Raises:
          AttributeError: The key does not have the casefold method.
        """
        try:
            return key.casefold()  # type: ignore
        except AttributeError:
            # Probably a byte string, fall back to lower()
            return key.lower()

    # Basic accessor and setter methods

    def __getitem__(self, key: Key) -> Any:
        """
        Return the value of the item with an existing key (looked up
        case-insensitively).

        Invoked when using e.g.: ``value = ncd[key]``

        Raises:
          AttributeError: The key does not have the casefold method.
          KeyError: Key does not exist (case-insensitively).
        """
        k = self._casefolded_key(key)
        try:
            return self._data[k][1]
        except KeyError:
            key_error = KeyError(f"Key {key!r} not found")
            key_error.__cause__ = None  # Suppress 'During handling..'
            raise key_error  # pylint: disable=raise-missing-from

    def __setitem__(self, key: Key, value: Any) -> None:
        """
        Update the value of the item with an existing key (looked up
        case-insensitively), or if an item with the key does not exist, add an
        item with the specified key and value.

        Invoked when using e.g.: ``ncd[key] = value``

        Raises:
          AttributeError: The key does not have the casefold method.
        """
        k = self._casefolded_key(key)
        self._data[k] = (key, value)

    def __delitem__(self, key: Key) -> None:
        """
        Delete the item with an existing key (looked up case-insensitively).

        Invoked when using: ``del ncd[key]``

        Raises:
          AttributeError: The key does not have the casefold method.
          KeyError: Key does not exist (case-insensitively).
        """
        k = self._casefolded_key(key)
        try:
            del self._data[k]
        except KeyError:
            key_error = KeyError(f"Key {key!r} not found")
            key_error.__cause__ = None  # Suppress 'During handling..'
            raise key_error  # pylint: disable=raise-missing-from

    def __len__(self) -> int:
        """
        Return the number of items in the dictionary.

        Invoked when using: ``len(ncd)``
        """
        return len(self._data)

    def __contains__(self, key: Any) -> bool:
        """
        Return a boolean indicating whether the dictionary contains an item
        with the key (looked up case-insensitively).

        Invoked when using: ``key in ncd``

        Raises:
          AttributeError: The key does not have the casefold method.
        """
        k = self._casefolded_key(key)
        return k in self._data

    def __reversed__(self) -> Iterator[Any]:
        """
        Return an iterator for the reversed iteration order of the dictionary.

        Invoked when using: ``reversed[ncd]``
        """
        # Implementing __reversed__() is necessary because the fall back of
        # reversed() to using len() and __getitem__() (the sequence protocol")
        # requires that the object is a sequence, and relying on the fallback
        # for dicts results in TypeError.
        return reversed(self.keys())

    @classmethod
    def fromkeys(cls, iterable, value=None) -> 'NocaseDict':
        """
        Return a new :class:`NocaseDict` object with keys from the specified
        iterable of keys, and values all set to the specified value.

        Raises:
          AttributeError: The key does not have the casefold method.
        """
        return cls([(key, value) for key in iterable])

    def get(self, key: Key, default=None) -> Any:
        """
        Return the value of the item with an existing key (looked up
        case-insensitively), or if the key does not exist, a default value.

        Raises:
          AttributeError: The key does not have the casefold method.
        """
        try:
            return self[key]
        except KeyError:
            return default

    def pop(self, key: Key, default=_OMITTED) -> Any:
        """
        Remove the item with the specified key if it exists (looked up
        case-insensitively), and return its value.

        If an item with the key does not exist, the default value is returned
        if specified, otherwise :exc:`py:KeyError` is raised.

        Raises:
          KeyError: Key does not exist (case-insensitively) and no default was
            specified.
        """
        k = self._casefolded_key(key)
        try:
            return self._data.pop(k)[1]
        except KeyError:
            if default is not _OMITTED:
                return default
            raise

    def popitem(self) -> Tuple[Key, Any]:
        """
        Remove the last dictionary item (in iteration order) and return it as a
        tuple (key, value).

        The last item in iteration order is the last item that was added to the
        dictionary.

        Raises:
          KeyError: Dictionary is empty.
        """
        return self._data.popitem()[1]

    def setdefault(self, key: Key, default=None) -> Any:
        """
        If an item with the key (looked up case-insensitively) does not exist,
        add an item with that key and the specified default value, and return
        the value of the item with the key.

        Raises:
          AttributeError: The key does not have the casefold method.
        """
        if key not in self:
            self[key] = default
        return self[key]

    # Iteration methods

    def keys(self) -> dict_keys:
        # pylint: disable=line-too-long
        """
        Return a view on the dictionary keys (in the original lexical case) in
        dictionary iteration order.

        See
        `Dictionary View Objects <https://docs.python.org/3/library/stdtypes.html#dictionary-view-objects>`_ for details about view objects.
        """  # noqa: E501
        # pylint: enable=line-too-long
        return dict_keys(self)

    def keys_nocase(self) -> KeysView:
        # pylint: disable=line-too-long
        """
        Return a view on the casefolded dictionary keys in dictionary iteration
        order.

        See
        `Dictionary View Objects <https://docs.python.org/3/library/stdtypes.html#dictionary-view-objects>`_ for details about view objects.
        """  # noqa: E501
        # pylint: enable=line-too-long
        return self._data.keys()

    def values(self) -> dict_values:
        # pylint: disable=line-too-long
        """
        Return a view on the dictionary values in dictionary iteration order.

        See
        `Dictionary View Objects <https://docs.python.org/3/library/stdtypes.html#dictionary-view-objects>`_ for details about view objects.
        """  # noqa: E501
        # pylint: enable=line-too-long
        return dict_values(self)

    def items(self) -> dict_items:
        # pylint: disable=line-too-long
        """
        Return a view on the dictionary items in dictionary iteration order,
        where each item is a tuple of its key (in the original lexical case)
        and its value.

        See
        `Dictionary View Objects on <https://docs.python.org/3/library/stdtypes.html#dictionary-view-objects>`_ for details about view objects.
        """  # noqa: E501
        # pylint: enable=line-too-long
        return dict_items(self)

    def __iter__(self) -> Iterator[Key]:
        """
        Return an iterator through the dictionary keys (in the original lexical
        case) in dictionary iteration order.

        Invoked when using: ``for key in ncd``
        """
        for k in self._data:
            yield self._data[k][0]

    # Other stuff

    def __repr__(self) -> str:
        """
        Return a string representation of the dictionary that is suitable for
        debugging.

        The order of items is in dictionary iteration order, and the keys are
        in the original lexical case.

        Invoked when using e.g.: ``repr(ncd)``
        """
        items = [f"{key!r}: {value!r}" for key, value in self.items()]
        items_str = ', '.join(items)
        return f"{self.__class__.__name__}({{{items_str}}})"

    def update(self, *args, **kwargs) -> None:
        # pylint: disable=arguments-differ,signature-differs
        # Note: The signature in Python 3 is: update(self, other=(), /, **kwds)
        #       Since the / marker cannot be used in Python 2, the *args
        #       approach has the same effect, i.e. to ensure that the
        #       parameter can only be specified as a keyword argument.
        """
        Update the dictionary from key/value pairs.

        If a key is already present in the dictionary (looked up
        case-insensitively), its key and value is updated (without affecting
        its position in the dictionary iteration order). Otherwise, an item
        with the key and value is added to the dictionary.

        The provided key and value objects will be referenced from the
        dictionary without being copied, consistent with the built-in
        :class:`py:dict` class.

        Parameters:

          *args : An optional single positional argument representing key-value
            pairs to update the dictionary from, in iteration order of the
            specified object. The argument must be one of:

            - a dictionary object, or more specifically an object that has a
              method ``keys()`` providing iteration through the keys and that
              supports subscription by key for accessing the values.

            - an iterable. If a key occurs more than once (case-insensitively),
              the last item for that key becomes the corresponding item in
              the dictionary. Each item in the iterable must be one of:

              * an iterable with exactly two items. The first item is used as
                the key, and the second item as the value.

              * an object with a key attribute, if the
                :func:`~nocasedict.KeyableByMixin` mixin generator function is
                used. The value of the key attribute is used as the key, and
                the object itself as the value.

          **kwargs : Optional keyword arguments representing key-value pairs to
            update the dictionary from, after having processed the positional
            argument.

            Before Python 3.7, the order of keyword arguments as specified in
            the call to the method was not guaranteed to be preserved for the
            method implementation, so passing more than one keyword argument
            may have resulted in arbitrary order of items in the dictionary.

        Raises:
          AttributeError: The key does not have the casefold method.
          TypeError: Expected at most 1 positional argument, got {n}.
          ValueError: Cannot unpack positional argument item #{i}.
        """
        if args:
            if len(args) > 1:
                raise TypeError(
                    f"Expected at most 1 positional argument, got {len(args)}")
            other = args[0]
            try:
                # Try mapping / dictionary
                for key in other.keys():
                    self[key] = other[key]
            except AttributeError:
                # Expecting an iterable

                # Try whether KeyableByMixin() was used
                key_attr = getattr(
                    self, 'nocasedict_KeyableByMixin_key_attr', None)
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
                                f"Cannot unpack positional argument item #{i} "
                                f"of type {type(item)} into key, value: {exc}")
                            value_error.__cause__ = None  # Suppress 'During..'
                            # pylint: disable=raise-missing-from
                            raise value_error
                    self[key] = value

        for key, val in kwargs.items():
            self[key] = val

    def clear(self) -> None:
        """
        Remove all items from the dictionary.
        """
        self._data.clear()

    def copy(self) -> 'NocaseDict':
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

    def __eq__(self, other: Any) -> bool:
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
          AttributeError: The key does not have the casefold method.
        """
        # Issue #1062: Could compare hash values for better performance
        for key, self_value in self.items():
            if key not in other:
                return False
            other_value = other[key]
            try:
                if not self_value == other_value:
                    return False
            except TypeError:
                return False  # not comparable -> considered not equal
        return len(self) == len(other)

    def __ne__(self, other: Any) -> bool:
        """
        Return a boolean indicating whether the dictionary and the other
        dictionary are not equal, by negating the equality test.

        The other dictionary may be a :class:`NocaseDict` object or any other
        mapping. In all cases, the matching of keys takes place
        case-insensitively.

        Invoked when using e.g.: ``ncd != other``

        Raises:
          AttributeError: The key does not have the casefold method.
        """
        return not self == other

    def _raise_ordering_not_supported(self, other: Any, op: str) -> NoReturn:
        """
        Function to raise a TypeError indicating that ordering of this class
        is not supported.
        """
        raise TypeError(
            f"'{op}' not supported between instances of '{type(self)}' and "
            f"'{type(other)}'")

    def __lt__(self, other: Any) -> NoReturn:
        self._raise_ordering_not_supported(other, '<')

    def __gt__(self, other: Any) -> NoReturn:
        self._raise_ordering_not_supported(other, '>')

    def __ge__(self, other: Any) -> NoReturn:
        self._raise_ordering_not_supported(other, '>=')

    def __le__(self, other: Any) -> NoReturn:
        self._raise_ordering_not_supported(other, '<=')
