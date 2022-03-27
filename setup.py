#!/usr/bin/env python
"""
Python setup script for the nocasedict project.
"""

import sys
import os
import io
import re
import setuptools


def get_version(version_file):
    """
    Execute the specified version file and return the value of the __version__
    global variable that is set in the version file.

    Note: Make sure the version file does not depend on any packages in the
    requirements list of this package (otherwise it cannot be executed in
    a fresh Python environment).
    """
    with io.open(version_file, 'r', encoding='utf-8') as fp:
        version_source = fp.read()
    _globals = {}
    exec(version_source, _globals)  # pylint: disable=exec-used
    return _globals['__version__']


def get_requirements(requirements_file):
    """
    Parse the specified requirements file and return a list of its non-empty,
    non-comment lines. The returned lines are without any trailing newline
    characters.
    """
    with io.open(requirements_file, 'r', encoding='utf-8') as fp:
        lines = fp.readlines()
    reqs = []
    for line in lines:
        line = line.strip('\n')
        if not line.startswith('#') and line != '':
            reqs.append(line)
    return reqs


def read_file(a_file):
    """
    Read the specified file and return its content as one string.
    """
    with io.open(a_file, 'r', encoding='utf-8') as fp:
        content = fp.read()
    return content


class PytestCommand(setuptools.Command):
    """
    Base class for setup.py commands for executing tests for this package
    using pytest.

    Note on the class name: Because distutils.dist._show_help() shows the class
    name for the setup.py command name instead of invoking get_command_name(),
    the classes that get registered as commands must have the command name.
    """

    description = None  # Set by subclass
    my_test_dirs = None  # Set by subclass

    user_options = [
        (
            'pytest-options=',  # '=' indicates it requires an argument
            None,  # no short option
            "additional options for pytest, as one argument"
        ),
    ]

    def initialize_options(self):
        """
        Standard method called by setup to initialize options for the command.
        """
        # pylint: disable=attribute-defined-outside-init
        self.test_opts = None
        self.test_dirs = None
        self.pytest_options = None
        # pylint: enable=attribute-defined-outside-init

    def finalize_options(self):
        """
        Standard method called by setup to finalize options for the command.
        """
        # pylint: disable=attribute-defined-outside-init
        self.test_opts = [
            '--color=yes',
            '-s',
            '-W', 'default',
            '-W', 'ignore::PendingDeprecationWarning',
        ]
        if sys.version_info[0] == 3:
            self.test_opts.extend([
                '-W', 'ignore::ResourceWarning',
            ])
        self.test_dirs = self.my_test_dirs
        # pylint: enable=attribute-defined-outside-init

    def run(self):
        """
        Standard method called by setup to execute the command.
        """

        # deferred import so install does not depend on it
        import pytest  # pylint: disable=import-outside-toplevel

        args = self.test_opts
        if self.pytest_options:
            args.extend(self.pytest_options.split(' '))
        args.extend(self.test_dirs)

        if self.dry_run:
            self.announce("Dry-run: pytest {}".format(' '.join(args)), level=1)
            return 0

        self.announce("pytest {}".format(' '.join(args)), level=1)
        rc = pytest.main(args)
        return rc


class test(PytestCommand):
    # pylint: disable=invalid-name
    """
    Setup.py command for executing unit and function tests.
    """
    description = "nocasedict: Run unit tests using pytest"
    my_test_dirs = ['tests/unittest']


# pylint: disable=invalid-name
requirements = get_requirements('requirements.txt')
install_requires = [req for req in requirements
                    if req and not re.match(r'[^:]+://', req)]
dependency_links = [req for req in requirements
                    if req and re.match(r'[^:]+://', req)]
test_requirements = get_requirements('test-requirements.txt')

package_version = get_version(os.path.join('nocasedict', '_version.py'))

# Docs on setup():
# * https://docs.python.org/2.7/distutils/apiref.html?
#   highlight=setup#distutils.core.setup
# * https://setuptools.readthedocs.io/en/latest/setuptools.html#
#   new-and-changed-setup-keywords
setuptools.setup(
    name='nocasedict',
    version=package_version,
    packages=[
        'nocasedict',
    ],
    include_package_data=True,  # Includes MANIFEST.in files into sdist (only)
    scripts=[
        # add any scripts
    ],
    install_requires=install_requires,
    dependency_links=dependency_links,
    extras_require={
        "test": test_requirements,
    },
    cmdclass={
        'test': test,
    },
    description="A case-insensitive ordered dictionary for Python",
    long_description=read_file('README.rst'),
    long_description_content_type='text/x-rst',
    license="GNU Lesser General Public License v2 or later (LGPLv2+)",
    author="Andreas Maier",
    author_email='andreas.r.maier@gmx.de',
    maintainer="Andreas Maier",
    maintainer_email='andreas.r.maier@gmx.de',
    url='https://github.com/pywbem/nocasedict',
    project_urls={
        'Bug Tracker': 'https://github.com/pywbem/nocasedict/issues',
        'Documentation': 'https://nocasedict.readthedocs.io/en/latest/',
        'Source Code': 'https://github.com/pywbem/nocasedict',
    },

    options={'bdist_wheel': {'universal': True}},
    zip_safe=True,  # This package can safely be installed from a zip file
    platforms='any',

    python_requires='>=2.7, !=3.0.*, !=3.1.*, !=3.2.*, !=3.3.*',
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: '
        'GNU Lesser General Public License v2 or later (LGPLv2+)',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ]
)
