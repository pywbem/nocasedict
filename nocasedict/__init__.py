"""
nocasedict - A case-insensitive dictionary for Python
"""

# There are submodules, but users shouldn't need to know about them.
# Importing just this module is enough.

from __future__ import absolute_import
import sys
from ._version import __version__  # noqa: F401

_PY_M = sys.version_info[0]
_PY_N = sys.version_info[1]

# Keep these Python versions in sync with setup.py
if _PY_M == 2 and _PY_N < 7:
    raise RuntimeError(
        "On Python 2, nocasedict requires "
        "Python 2.7")
if _PY_M == 3 and _PY_N < 4:
    raise RuntimeError(
        "On Python 3, nocasedict requires "
        "Python 3.4 or higher")
