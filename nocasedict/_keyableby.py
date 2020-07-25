"""
This module provides function KeyableByMixin() returning a mixin class for
class NocaseDict.
"""

from __future__ import print_function, absolute_import

__all__ = ['KeyableByMixin']


def KeyableByMixin(key_attr):
    # pylint: disable=invalid-name
    """
    A function returning a mixin class that adds the ability to a dictionary
    to initialize or update the dictionary from an iterable of objects, whereby
    a particular attribute of the object is used as the key.

    This simplifies the initialization of dictionaries because simple lists
    or tuples of such objects can be provided.

    The derived class inheriting from the returned mixin class must also
    (directly or indirectly) inherit from :class:`~nocasedict.NocaseDict`.

    Example::

        from nocasedict import NocaseDict, KeyableByMixin

        class MyDict(KeyableByMixin('name'), NocaseDict):
            pass

        class Obj(object):
            def __init__(self, name, value):
                self.name = name
                self.value = value

        md = MyDict([Obj('A', 1), Obj('B', 2)])

        print(md)
        # MyDict({'A': <__main__.Obj object at 0x10bc3d820>,
        #         'B': <__main__.Obj object at 0x10bc89af0>})
    """
    return type('KeyableBy_{}_Mixin'.format(key_attr),
                (), dict(nocasedict_KeyableBy_key_attr=key_attr))
