"""
Test the KeyableByMixin() mixin function.
"""

from __future__ import absolute_import

import os
import pytest

from ..utils.simplified_test_function import simplified_test_function

# pylint: disable=wrong-import-position, wrong-import-order, invalid-name
from ..utils.import_installed import import_installed
nocasedict = import_installed('nocasedict')
from nocasedict import NocaseDict as _NocaseDict  # noqa: E402
from nocasedict import KeyableByMixin  # noqa: E402
# pylint: enable=wrong-import-position, wrong-import-order, invalid-name

# Controls whether the tests are run against a standard dict instead.
TEST_AGAINST_DICT = os.getenv('TEST_DICT')

if TEST_AGAINST_DICT:
    print("\nInfo: test_keyableby.py tests run against standard dict")

# The dictionary class being tested
# pylint: disable=invalid-name
NocaseDict = dict if TEST_AGAINST_DICT else _NocaseDict


class MyKey_NocaseDict(KeyableByMixin('my_key'), NocaseDict):
    # pylint: disable=too-few-public-methods
    """
    The keyable NocaseDict class being tested.
    """
    pass


class MyKey_KeyableByMixin(object):
    # pylint: disable=too-few-public-methods
    """
    Expected mixin class for a key attribute named 'my_key'.
    """

    nocasedict_KeyableByMixin_key_attr = 'my_key'


class MyKey_Object(object):
    # pylint: disable=too-few-public-methods
    """
    Class that has an instance attribute named 'my_key'.
    """

    def __init__(self, my_key):
        self.my_key = my_key

    def __eq__(self, other):
        self.my_key = other.my_key


def test_KeyableByMixin():
    """
    Test function for KeyableByMixin()
    """

    # The code to be tested
    mixin = KeyableByMixin('my_key')

    assert issubclass(mixin, object)
    assert mixin.nocasedict_KeyableByMixin_key_attr == \
        MyKey_KeyableByMixin.nocasedict_KeyableByMixin_key_attr


TESTCASES_KEYABLEBYMIXIN_INIT = [

    # Testcases for initialization from iterable with keyable object

    # Each list item is a testcase tuple with these items:
    # * desc: Short testcase description.
    # * kwargs: Keyword arguments for the test function:
    #   * ncd_class: dict class for testing initialization.
    #   * key_attr: Name of key attrbute of keyable objects.
    #   * init_arg: Input argument for testing initialization.
    #   * exp_tuples: Expected list of tuples in initialized dict.
    # * exp_exc_types: Expected exception type(s), or None.
    # * exp_warn_types: Expected warning type(s), or None.
    # * condition: Boolean condition for testcase to run, or 'pdb' for debugger

    (
        "Iterable with two keyable objects",
        dict(
            ncd_class=MyKey_NocaseDict,
            init_arg=[MyKey_Object('Dog'), MyKey_Object('Cat')],
            exp_tuples=[('Dog', MyKey_Object('Dog')),
                        ('Cat', MyKey_Object('Cat'))]
        ),
        None, None, True
    ),
    (
        "Iterable with one key,value tuple and one keyable object",
        dict(
            ncd_class=MyKey_NocaseDict,
            init_arg=[('Dog', 42), MyKey_Object('Cat')],
            exp_tuples=[('Dog', 42),
                        ('Cat', MyKey_Object('Cat'))]
        ),
        None, None, True
    ),
]


@pytest.mark.parametrize(
    "desc, kwargs, exp_exc_types, exp_warn_types, condition",
    TESTCASES_KEYABLEBYMIXIN_INIT)
@simplified_test_function
def test_KeyableByMixin_init(testcase, ncd_class, init_arg, exp_tuples):
    """
    Test function for initialization from iterable with keyable object.
    """

    if TEST_AGAINST_DICT:
        pytest.skip("dict does not support keyables")

    ncd = ncd_class(init_arg)

    # Ensure that exceptions raised in the remainder of this function
    # are not mistaken as expected exceptions
    assert testcase.exp_exc_types is None

    assert len(ncd) == len(exp_tuples)
    for exp_key, exp_value in exp_tuples:
        assert exp_key in ncd
        value = ncd[exp_key]
        # pylint: disable=unidiomatic-typecheck
        assert type(value) == type(exp_value)
