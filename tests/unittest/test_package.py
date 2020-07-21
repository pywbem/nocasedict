"""
Test import and versioning of the package.
"""


def test_import():
    """
    Test import of the package.
    """
    import nocaselist  # noqa: F401 pylint: disable=import-outside-toplevel
    assert nocaselist


def test_versioning():
    """
    Test import of the package.
    """
    import nocaselist  # noqa: F401 pylint: disable=import-outside-toplevel
    assert nocaselist.__version__
