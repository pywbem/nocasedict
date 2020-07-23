"""
Test the HashableMixin mixin class.
"""

from __future__ import absolute_import

import os
import pytest

from ..utils.simplified_test_function import simplified_test_function

# pylint: disable=wrong-import-position, wrong-import-order, invalid-name
from ..utils.import_installed import import_installed
nocasedict = import_installed('nocasedict')
from nocasedict import NocaseDict as _NocaseDict  # noqa: E402
from nocasedict import HashableMixin  # noqa: E402
# pylint: enable=wrong-import-position, wrong-import-order, invalid-name

# Controls whether the tests are run against a standard dict instead.
TEST_AGAINST_DICT = os.getenv('TEST_DICT')

if TEST_AGAINST_DICT:
    print("\nInfo: test_hashable.py tests run against standard dict")

# The dictionary class being tested
# pylint: disable=invalid-name
NocaseDict = dict if TEST_AGAINST_DICT else _NocaseDict


class MyNocaseDict(HashableMixin, NocaseDict):
    # pylint: disable=too-few-public-methods
    """
    The hashable NocaseDict class being tested.
    """
    pass


class NonHashable(object):
    # pylint: disable=too-few-public-methods
    """
    Class that raises TypeError when hashing its objects.
    """

    def __hash__(self):
        raise TypeError("Cannot hash %s" % type(self))


TESTCASES_HASHABLEMIXIN_HASH = [

    # Testcases for HashableMixin.__hash__()

    # Each list item is a testcase tuple with these items:
    # * desc: Short testcase description.
    # * kwargs: Keyword arguments for the test function:
    #   * obj1: MyNocaseDict object #1 to use.
    #   * obj2: MyNocaseDict object #2 to use.
    #   * exp_obj_equal: Expected equality of the objects.
    # * exp_exc_types: Expected exception type(s), or None.
    # * exp_warn_types: Expected warning type(s), or None.
    # * condition: Boolean condition for testcase to run, or 'pdb' for debugger

    (
        "Empty dictionary",
        dict(
            obj1=MyNocaseDict([]),
            obj2=MyNocaseDict([]),
            exp_obj_equal=True,
        ),
        None, None, True
    ),
    (
        "One item, keys and values equal",
        dict(
            obj1=MyNocaseDict([('k1', 'v1')]),
            obj2=MyNocaseDict([('k1', 'v1')]),
            exp_obj_equal=True,
        ),
        None, None, True
    ),
    (
        "One item, keys equal, values different",
        dict(
            obj1=MyNocaseDict([('k1', 'v1')]),
            obj2=MyNocaseDict([('k1', 'v1_x')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "One item, keys different, values equal",
        dict(
            obj1=MyNocaseDict([('k1', 'v1')]),
            obj2=MyNocaseDict([('k2', 'v1')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "One item, keys equal, values both None",
        dict(
            obj1=MyNocaseDict([('k1', None)]),
            obj2=MyNocaseDict([('k1', None)]),
            exp_obj_equal=True,
        ),
        None, None, True
    ),
    (
        "One item, keys different lexical case, values equal",
        dict(
            obj1=MyNocaseDict([('K1', 'v1')]),
            obj2=MyNocaseDict([('k1', 'v1')]),
            exp_obj_equal=not TEST_AGAINST_DICT,
        ),
        None, None, True
    ),
    (
        "Two equal items, in same order",
        dict(
            obj1=MyNocaseDict([('k1', 'v1'), ('k2', 'v2')]),
            obj2=MyNocaseDict([('k1', 'v1'), ('k2', 'v2')]),
            exp_obj_equal=True,
        ),
        None, None, True
    ),
    (
        "Two items, keys different lexical case, in same order",
        dict(
            obj1=MyNocaseDict([('K1', 'v1'), ('k2', 'v2')]),
            obj2=MyNocaseDict([('k1', 'v1'), ('K2', 'v2')]),
            exp_obj_equal=not TEST_AGAINST_DICT,
        ),
        None, None, True
    ),
    (
        "Two equal items, in different order",
        dict(
            obj1=MyNocaseDict([('k1', 'v1'), ('k2', 'v2')]),
            obj2=MyNocaseDict([('k2', 'v2'), ('k1', 'v1')]),
            exp_obj_equal=True,
        ),
        None, None, True
    ),
    (
        "Two items, keys different lexical case, in different order",
        dict(
            obj1=MyNocaseDict([('k1', 'v1'), ('K2', 'v2')]),
            obj2=MyNocaseDict([('k2', 'v2'), ('K1', 'v1')]),
            exp_obj_equal=not TEST_AGAINST_DICT,
        ),
        None, None, True
    ),
    (
        "Comparing unicode value with bytes value",
        dict(
            obj1=MyNocaseDict([('k1', b'v1')]),
            obj2=MyNocaseDict([('k2', u'v2')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "Matching unicode key with string key",
        dict(
            obj1=MyNocaseDict([('k1', 'v1')]),
            obj2=MyNocaseDict([(u'k2', 'v2')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "Higher key missing",
        dict(
            obj1=MyNocaseDict([('Budgie', 'Fish'), ('Dog', 'Cat')]),
            obj2=MyNocaseDict([('Budgie', 'Fish')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "Lower key missing",
        dict(
            obj1=MyNocaseDict([('Budgie', 'Fish'), ('Dog', 'Cat')]),
            obj2=MyNocaseDict([('Dog', 'Cat')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "First non-matching key is less. But longer size!",
        dict(
            obj1=MyNocaseDict([('Budgie', 'Fish'), ('Dog', 'Cat')]),
            obj2=MyNocaseDict([('Budgie', 'Fish'), ('Curly', 'Snake'),
                               ('Cozy', 'Dog')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "Only non-matching keys that are less. But longer size!",
        dict(
            obj1=MyNocaseDict([('Budgie', 'Fish'), ('Dog', 'Cat')]),
            obj2=MyNocaseDict([('Alf', 'F'), ('Anton', 'S'), ('Aussie', 'D')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "First non-matching key is greater. But shorter size!",
        dict(
            obj1=MyNocaseDict([('Budgie', 'Fish'), ('Dog', 'Cat')]),
            obj2=MyNocaseDict([('Budgio', 'Fish')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "Only non-matching keys that are greater. But shorter size!",
        dict(
            obj1=MyNocaseDict([('Budgie', 'Fish'), ('Dog', 'Cat')]),
            obj2=MyNocaseDict([('Zoe', 'F')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "Same size. First non-matching key is less",
        dict(
            obj1=MyNocaseDict([('Budgie', 'Fish'), ('Dog', 'Cat')]),
            obj2=MyNocaseDict([('Budgie', 'Fish'), ('Curly', 'Snake')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "Same size. Only non-matching keys that are less",
        dict(
            obj1=MyNocaseDict([('Budgie', 'Fish'), ('Dog', 'Cat')]),
            obj2=MyNocaseDict([('Alf', 'F'), ('Anton', 'S')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "Same size. Only non-matching keys that are greater",
        dict(
            obj1=MyNocaseDict([('Budgie', 'Fish'), ('Dog', 'Cat')]),
            obj2=MyNocaseDict([('Zoe', 'F'), ('Zulu', 'S')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "Same size, only matching keys. First non-matching value is less",
        dict(
            obj1=MyNocaseDict([('Budgie', 'Fish'), ('Dog', 'Cat')]),
            obj2=MyNocaseDict([('Budgie', 'Fish'), ('Dog', 'Car')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "Same size, only matching keys. First non-matching value is greater",
        dict(
            obj1=MyNocaseDict([('Budgie', 'Fish'), ('Dog', 'Cat')]),
            obj2=MyNocaseDict([('Budgie', 'Fish'), ('Dog', 'Caz')]),
            exp_obj_equal=False,
        ),
        None, None, True
    ),
    (
        "A value raises TypeError when compared (and hash fails)",
        dict(
            obj1=MyNocaseDict([('Budgie', 'Fish'), ('Dog', 'Cat')]),
            obj2=MyNocaseDict([('Budgie', NonHashable()), ('Dog', 'Cat')]),
            exp_obj_equal=False,
        ),
        TypeError, None, True
    ),
]


@pytest.mark.parametrize(
    "desc, kwargs, exp_exc_types, exp_warn_types, condition",
    TESTCASES_HASHABLEMIXIN_HASH)
@simplified_test_function
def test_HashableMixin_hash(testcase, obj1, obj2, exp_obj_equal):
    """
    Test function for HashableMixin.__hash__() / hash(ncd)
    """

    if TEST_AGAINST_DICT:
        pytest.skip("dict is not hashable")

    # Double check they are different objects
    assert id(obj1) != id(obj2)

    # The code to be tested
    hash1 = hash(obj1)
    hash2 = hash(obj2)

    # Ensure that exceptions raised in the remainder of this function
    # are not mistaken as expected exceptions
    assert testcase.exp_exc_types is None

    if exp_obj_equal:
        assert hash1 == hash2
    else:
        assert hash1 != hash2
