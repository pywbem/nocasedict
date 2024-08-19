"""
Version of the nocasedict package.
"""

# In the RTD docs build, _version_scm.py does not exist:
try:
    from ._version_scm import version, version_tuple
except ImportError:
    version: str = "unknown"  # type: ignore
    version_tuple: tuple = tuple("unknown")  # type: ignore

__all__ = ['__version__', '__version_tuple__']

#: The full version of this package including any development levels, as a
#: string.
#:
#: Possible formats for this version string are:
#:
#: * "M.N.Pa1.dev7+g1234567": A not yet released version M.N.P
#: * "M.N.P": A released version M.N.P
__version__: str = version

#: The full version of this package including any development levels, as a
#: tuple of version items, converted to integer where possible.
#:
#: Possible formats for this version string are:
#:
#: * (M, N, P, 'a1', 'dev7', 'g1234567'): A not yet released version M.N.P
#: * (M, N, P): A released version M.N.P
__version_tuple__: tuple = version_tuple
