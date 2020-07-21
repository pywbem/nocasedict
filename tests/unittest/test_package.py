"""
Test import and versioning of the package.
"""


def test_import():
    """
    Test import of the package.
    """
    import nocasedict  # noqa: F401 pylint: disable=import-outside-toplevel
    assert nocasedict


def test_versioning():
    """
    Test import of the package.
    """
    import nocasedict  # noqa: F401 pylint: disable=import-outside-toplevel
    assert nocasedict.__version__
