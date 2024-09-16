# Makefile for the nocasedict project.
#
# Supported OS platforms for this Makefile:
#     Linux (any distro)
#     OS-X
#     Windows with UNIX-like env such as CygWin (with a UNIX-like shell and
#       Python in the UNIX-like env)
#     native Windows (with the native Windows command processor and Python in
#       Windows)
#
# Prerequisites for running this Makefile:
#   These commands are used on all supported OS platforms. On native Windows,
#   they may be provided by UNIX-like environments such as CygWin:
#     make (GNU make)
#     python (This Makefile uses the active Python environment, virtual Python
#       environments are supported)
#     pip (in the active Python environment)
#     twine (in the active Python environment)
#   These additional commands are used on Linux, OS-X and on Windows with
#   UNIX-like environments:
#     uname
#     rm, find, xargs, cp
#   These additional commands are used on native Windows:
#     del, copy, rmdir

# No built-in rules needed:
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

# Python / Pip commands
ifndef PYTHON_CMD
  PYTHON_CMD := python
endif
ifndef PIP_CMD
  PIP_CMD := pip
endif

# Pip options that are always to be used
pip_opts := --disable-pip-version-check

# Package level
ifndef PACKAGE_LEVEL
  PACKAGE_LEVEL := latest
endif
ifeq ($(PACKAGE_LEVEL),minimum)
  pip_level_opts := -c minimum-constraints.txt
else
  ifeq ($(PACKAGE_LEVEL),latest)
    pip_level_opts := --upgrade --upgrade-strategy eager
  else
    $(error Error: Invalid value for PACKAGE_LEVEL variable: $(PACKAGE_LEVEL))
  endif
endif

# Make variables are case sensitive and some native Windows environments have
# ComSpec set instead of COMSPEC.
ifndef COMSPEC
  ifdef ComSpec
    COMSPEC = $(ComSpec)
  endif
endif

# Determine OS platform make runs on.
#
# The PLATFORM variable is set to one of:
# * Windows_native: Windows native environment (the Windows command processor
#   is used as shell and its internal commands are used, such as "del").
# * Windows_UNIX: A UNIX-like envieonment on Windows (the UNIX shell and its
#   internal commands are used, such as "rm").
# * Linux: Some Linux distribution
# * Darwin: OS-X / macOS
#
# This in turn determines the type of shell that is used by make when invoking
# commands, and the set of internal shell commands that is assumed to be
# available (e.g. "del" for the Windows native command processor and "rm" for
# a UNIX-like shell). Note that GNU make always uses the value of the SHELL
# make variable to invoke the shell for its commands, but it does not always
# read that variable from the environment. In fact, the approach GNU make uses
# to set the SHELL make variable is very special, see
# https://www.gnu.org/software/make/manual/html_node/Choosing-the-Shell.html.
# On native Windows this seems to be implemented differently than described:
# SHELL is not set to COMSPEC, so we do that here.
#
# Note: Native Windows and CygWin are hard to distinguish: The native Windows
# envvars are set in CygWin as well. COMSPEC (or ComSpec) is set on both
# platforms. Using "uname" will display CYGWIN_NT-.. on both platforms. If the
# CygWin make is used on native Windows, most of the CygWin behavior is visible
# in context of that make (e.g. a SHELL variable is set, PATH gets converted to
# UNIX syntax, execution of batch files requires execute permission, etc.).
ifeq ($(OS),Windows_NT)
  ifdef PWD
    PLATFORM := Windows_UNIX
  else
    PLATFORM := Windows_native
    ifdef COMSPEC
      SHELL := $(subst \,/,$(COMSPEC))
    else
      SHELL := cmd.exe
    endif
    .SHELLFLAGS := /c
  endif
  # Note: On native Windows with Python 3.8, Pip fails with "ERROR: To modify
  # pip ...", even when the package does not require Pip (e.g. for six).
  PIP_CMD_MOD := $(PYTHON_CMD) -m pip
else
  # Values: Linux, Darwin
  PLATFORM := $(shell uname -s)
  PIP_CMD_MOD := $(PIP_CMD)
endif

ifeq ($(PLATFORM),Windows_native)
  # Note: The substituted backslashes must be doubled.
  # Remove files (blank-separated list of wildcard path specs)
  RM_FUNC = del /f /q $(subst /,\\,$(1))
  # Remove files recursively (single wildcard path spec)
  RM_R_FUNC = del /f /q /s $(subst /,\\,$(1))
  # Remove directories (blank-separated list of wildcard path specs)
  RMDIR_FUNC = rmdir /q /s $(subst /,\\,$(1))
  # Remove directories recursively (single wildcard path spec)
  RMDIR_R_FUNC = rmdir /q /s $(subst /,\\,$(1))
  # Copy a file, preserving the modified date
  CP_FUNC = copy /y $(subst /,\\,$(1)) $(subst /,\\,$(2))
  ENV = set
  WHICH = where
else
  RM_FUNC = rm -f $(1)
  RM_R_FUNC = find . -type f -name '$(1)' -delete
  RMDIR_FUNC = rm -rf $(1)
  RMDIR_R_FUNC = find . -type d -name '$(1)' | xargs -n 1 rm -rf
  CP_FUNC = cp -r $(1) $(2)
  ENV = env | sort
  WHICH = which -a
endif

# Name of this project
project_name := nocasedict

# Name of this Python package
package_name := nocasedict

# Determine if coverage details report generated
# The variable can be passed in as either an environment variable or
# command line variable. When set, generates a set of reports of the
# Python source files showing line by line coverage.
ifdef COVERAGE_REPORT
  coverage_report := --cov-report=annotate --cov-report=html
else
  coverage_report :=
endif

# Directory for coverage html output. Must be in sync with the one in .coveragerc.
coverage_html_dir := coverage_html

# Package version (full version, including any pre-release suffixes, e.g. "0.1.0.dev1").
# Note: The package version is defined in _version.py.
package_version := $(shell $(PYTHON_CMD) setup.py --version)

# Python versions and bit size
python_full_version := $(shell $(PYTHON_CMD) -c "import sys; sys.stdout.write('{v[0]}.{v[1]}.{v[2]}'.format(v=sys.version_info))")
python_mn_version := $(shell $(PYTHON_CMD) -c "import sys; sys.stdout.write('{v[0]}.{v[1]}'.format(v=sys.version_info))")
python_m_version := $(shell $(PYTHON_CMD) -c "import sys; sys.stdout.write('{v[0]}'.format(v=sys.version_info))")
python_bitsize := $(shell $(PYTHON_CMD) -c "import sys,ctypes; sys.stdout.write(f'{ctypes.sizeof(ctypes.c_void_p)*8}')")
pymn := py$(python_mn_version)

# Directory for the generated distribution files
dist_dir := dist

# Distribution archives
# These variables are set with "=" for the same reason as package_version.
bdist_file = $(dist_dir)/$(package_name)-$(package_version)-py2.py3-none-any.whl
sdist_file = $(dist_dir)/$(package_name)-$(package_version).tar.gz

dist_files = $(bdist_file) $(sdist_file)

# Source files in the packages
package_py_files := \
    $(wildcard $(package_name)/*.py) \
    $(wildcard $(package_name)/*/*.py) \

# Directory for generated API documentation
doc_build_dir := build_doc

# Directory where Sphinx conf.py and the docs source files is located
doc_dir := docs

# Paper format for the Sphinx LaTex/PDF builder.
# Valid values: a4, letter
doc_paper_format := a4

# Documentation generator command
doc_cmd := sphinx-build
doc_opts := -v -d $(doc_build_dir)/doctrees -c $(doc_dir) -D latex_elements.papersize=$(doc_paper_format) .

# Dependents for Sphinx documentation build
doc_dependent_files := \
    $(doc_dir)/conf.py \
    $(wildcard $(doc_dir)/*.rst) \
		$(wildcard $(package_name)/*.py) \

# PyLint config file
pylint_rc_file := pylintrc

# PyLint additional options
pylint_opts := --disable=fixme

# Mypy options
mypy_opts := --follow-imports skip

# Flake8 config file
flake8_rc_file := .flake8

# Safety policy file
safety_policy_file := .safety-policy.yml

# Test root directory
test_dir := tests

# Python source files to be checked by PyLint and Flake8
py_src_files := \
    setup.py \
    $(wildcard $(package_name)/*.py) \
    $(wildcard $(test_dir)/*.py) \
    $(wildcard $(test_dir)/*/*.py) \
    $(wildcard $(test_dir)/*/*/*.py) \
    $(wildcard $(test_dir)/*/*/*/*.py) \

ifdef TESTCASES
  pytest_opts := $(TESTOPTS) -k $(TESTCASES)
else
  pytest_opts := $(TESTOPTS)
endif
pytest_warning_opts := -W default -W ignore::PendingDeprecationWarning -W ignore::ResourceWarning
pytest_cov_opts := --cov $(package_name) $(coverage_report) --cov-config .coveragerc

# Files to be put into distribution archive.
# This is also used for 'include' statements in MANIFEST.in.
# Wildcards can be used directly (i.e. without wildcard function).
dist_included_files := \
    LICENSE \
    README.md \
    INSTALL.md \
    requirements.txt \
    test-requirements.txt \
    setup.py \
    $(package_name)/*.py \

# Directory for .done files
done_dir := done

# Packages whose dependencies are checked using pip-missing-reqs
ifeq ($(python_mn_version),3.6)
  check_reqs_packages := pytest coverage coveralls flake8 pylint twine
else
ifeq ($(python_mn_version),3.7)
  check_reqs_packages := pytest coverage coveralls flake8 pylint twine safety
else
  check_reqs_packages := pytest coverage coveralls flake8 pylint twine safety sphinx
endif
endif

.PHONY: help
help:
	@echo "Makefile for $(project_name) project"
	@echo "$(package_name) package version: $(package_version)"
	@echo ""
	@echo "Make targets:"
	@echo "  develop    - Set up development of $(project_name) project (installs $(package_name) as editable)"
	@echo "  build      - Build the distribution archive files in: $(dist_dir)"
	@echo "  builddoc   - Build documentation in: $(doc_build_dir)"
	@echo "  check      - Run Flake8 on Python sources"
	@echo "  pylint     - Run PyLint on Python sources"
	@echo "  mypy       - Run Mypy on Python sources"
	@echo "  safety     - Run safety on Python sources"
	@echo "  check_reqs - Perform missing dependency checks"
	@echo "  installtest - Run install tests"
	@echo "  test       - Run unit tests"
	@echo "  testdict   - Run unit tests against standard dict"
	@echo "  doclinkcheck - Run Sphinx linkcheck on the documentation"
	@echo "  authors    - Generate AUTHORS.md file from git log"
	@echo "  all        - Do all of the above"
	@echo "  install    - Install $(package_name) as standalone and its dependent packages"
	@echo "  upload     - build + upload the distribution archive files to PyPI"
	@echo "  clean      - Remove any temporary files"
	@echo "  clobber    - Remove everything created to ensure clean start"
	@echo "  pip_list   - Display the installed Python packages as seen by make"
	@echo "  platform   - Display the information about the platform as seen by make"
	@echo "  env        - Display the environment as seen by make"
	@echo ""
	@echo "Environment variables:"
	@echo "  COVERAGE_REPORT - When non-empty, the 'test' target creates a coverage report as"
	@echo "      annotated html files showing lines covered and missed, in the directory:"
	@echo "      $(coverage_html_dir)"
	@echo "      Optional, defaults to no such coverage report."
	@echo "  TESTCASES - When non-empty, 'test' target runs only the specified test cases. The"
	@echo "      value is used for the -k option of pytest (see 'pytest --help')."
	@echo "      Optional, defaults to running all tests."
	@echo "  TESTOPTS - Optional: Additional options for py.tests (see 'pytest --help')."
	@echo "  TEST_INSTALLED - When non-empty, run any tests using the installed version of $(package_name)"
	@echo "      and assume all Python and OS-level prerequisites are already installed."
	@echo "      When set to 'DEBUG', print location from where the $(package_name) package is loaded."
	@echo "  TEST_DICT - When non-empty, run unit tests against the standard dict."
	@echo "  PACKAGE_LEVEL - Package level to be used for installing dependent Python"
	@echo "      packages in 'install' and 'develop' targets:"
	@echo "        latest - Latest package versions available on Pypi"
	@echo "        minimum - A minimum version as defined in minimum-constraints.txt"
	@echo "      Optional, defaults to 'latest'."
	@echo "  PYTHON_CMD - Python command to be used. Useful for Python 3 in some envs."
	@echo "      Optional, defaults to 'python'."
	@echo "  PIP_CMD - Pip command to be used. Useful for Python 3 in some envs."
	@echo "      Optional, defaults to 'pip'."

.PHONY: platform
platform:
	@echo "Makefile: Platform related information as seen by make:"
	@echo "Platform: $(PLATFORM)"
	@echo "Shell used for commands: $(SHELL)"
	@echo "Shell flags: $(.SHELLFLAGS)"
	@echo "Make command location: $(MAKE)"
	@echo "Make version: $(MAKE_VERSION)"
	@echo "Python command name: $(PYTHON_CMD)"
	@echo "Python command location: $(shell $(WHICH) $(PYTHON_CMD))"
	@echo "Python version: $(python_full_version)"
	@echo "Python bit size: $(python_bitsize)"
	@echo "Pip command name: $(PIP_CMD)"
	@echo "Pip command location: $(shell $(WHICH) $(PIP_CMD))"
	@echo "Pip command for modifications: $(PIP_CMD_MOD)"
	@echo "Package $(package_name) version: $(package_version)"
	@echo "Package $(package_name) installation: $(shell $(PIP_CMD) $(pip_opts) show $(package_name) | grep Location)"
ifeq ($(PLATFORM),Windows_native)
	@echo "Available versions of MSVS on Windows:"
	-dir /b "C:\Program Files (x86)\Microsoft Visual Studio*"
	@echo "Available versions of Python on Windows (for GitHub Actions):"
	-dir /b "C:\hostedtoolcache\windows\Python"
endif

.PHONY: pip_list
pip_list:
	@echo "Makefile: Installed Python packages:"
	$(PIP_CMD) $(pip_opts) list

.PHONY: env
env:
	@echo "Makefile: Environment as seen by make:"
	$(ENV)

.PHONY: _check_version
_check_version:
ifeq (,$(package_version))
	$(error Package version could not be determined)
endif

.PHONY: _check_installed
_check_installed:
	@echo "Makefile: Verifying installation of package $(package_name)"
	$(PYTHON_CMD) -c "import $(package_name)"
	@echo "Makefile: Done verifying installation of package $(package_name)"

$(done_dir)/pip_upgrade_$(pymn)_$(PACKAGE_LEVEL).done: Makefile minimum-constraints.txt
	@echo "Makefile: Installing/upgrading Pip (with PACKAGE_LEVEL=$(PACKAGE_LEVEL))"
	-$(call RM_FUNC,$@)
	bash -c 'pv=$$($(PIP_CMD) --version); if [[ $$pv =~ (^pip [1-8]\..*) ]]; then $(PYTHON_CMD) -m pip $(pip_opts) install pip==9.0.1; fi'
	$(PYTHON_CMD) -m pip $(pip_opts) install $(pip_level_opts) pip
	echo "done" >$@
	@echo "Makefile: Done installing/upgrading Pip"

$(done_dir)/install_basic_$(pymn)_$(PACKAGE_LEVEL).done: Makefile $(done_dir)/pip_upgrade_$(pymn)_$(PACKAGE_LEVEL).done minimum-constraints.txt
	@echo "Makefile: Installing/upgrading basic Python packages (with PACKAGE_LEVEL=$(PACKAGE_LEVEL))"
	-$(call RM_FUNC,$@)
	$(PIP_CMD_MOD) $(pip_opts) install $(pip_level_opts) setuptools wheel
	echo "done" >$@
	@echo "Makefile: Done installing/upgrading basic Python packages"

$(done_dir)/install_reqs_$(pymn)_$(PACKAGE_LEVEL).done: Makefile $(done_dir)/install_basic_$(pymn)_$(PACKAGE_LEVEL).done requirements.txt minimum-constraints.txt
	@echo "Makefile: Installing Python installation prerequisites (with PACKAGE_LEVEL=$(PACKAGE_LEVEL))"
	-$(call RM_FUNC,$@)
	$(PIP_CMD_MOD) $(pip_opts) install $(pip_level_opts) -r requirements.txt
	echo "done" >$@
	@echo "Makefile: Done installing Python installation prerequisites"

$(done_dir)/develop_reqs_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/install_basic_$(pymn)_$(PACKAGE_LEVEL).done dev-requirements.txt test-requirements.txt minimum-constraints.txt
	@echo "Makefile: Installing development requirements (with PACKAGE_LEVEL=$(PACKAGE_LEVEL))"
	-$(call RM_FUNC,$@)
	$(PIP_CMD_MOD) $(pip_opts) install $(pip_level_opts) -r dev-requirements.txt
	echo "done" >$@
	@echo "Makefile: Done installing development requirements"

.PHONY: install
install: Makefile $(done_dir)/install_reqs_$(pymn)_$(PACKAGE_LEVEL).done setup.py
ifdef TEST_INSTALLED
	@echo "Makefile: Skipping installation of package $(package_name) as standalone because TEST_INSTALLED is set"
	@echo "Makefile: Checking whether package $(package_name) is actually installed:"
	$(PIP_CMD) $(pip_opts) show $(package_name)
else
ifeq ($(shell $(PIP_CMD) $(pip_opts) list --exclude-editable --format freeze | grep "$(package_name)=="),)
# if package is not installed as standalone
	@echo "Makefile: Installing package $(package_name) as standalone (with PACKAGE_LEVEL=$(PACKAGE_LEVEL))"
	-$(PIP_CMD_MOD) $(pip_opts) uninstall -y $(package_name)
	-$(call RMDIR_FUNC,$(package_name).egg-info)
	$(PIP_CMD_MOD) $(pip_opts) install .
	@echo "Makefile: Done installing package $(package_name) as standalone"
endif
endif
	@echo "Makefile: Verifying installation of package $(package_name)"
	$(PYTHON_CMD) -c "import $(package_name)"
	@echo "Makefile: Done verifying installation of package $(package_name)"
	@echo "Makefile: Target $@ done."

.PHONY: develop
develop: Makefile $(done_dir)/install_reqs_$(pymn)_$(PACKAGE_LEVEL).done $(done_dir)/develop_reqs_$(pymn)_$(PACKAGE_LEVEL).done setup.py
ifdef TEST_INSTALLED
	@echo "Makefile: Skipping installation of package $(package_name) as editable because TEST_INSTALLED is set"
	@echo "Makefile: Checking whether package $(package_name) is actually installed:"
	$(PIP_CMD) $(pip_opts) show $(package_name)
else
ifeq ($(shell $(PIP_CMD) $(pip_opts) list -e --format freeze | grep "$(package_name)=="),)
# if package is not installed as editable
	@echo "Makefile: Installing package $(package_name) as editable (with PACKAGE_LEVEL=$(PACKAGE_LEVEL))"
	-$(PIP_CMD_MOD) $(pip_opts) uninstall -y $(package_name)
	-$(call RMDIR_FUNC,$(package_name).egg-info)
	$(PIP_CMD_MOD) $(pip_opts) install -e .
	@echo "Makefile: Done installing package $(package_name) as editable"
endif
endif
	@echo "Makefile: Verifying installation of package $(package_name)"
	$(PYTHON_CMD) -c "import $(package_name)"
	@echo "Makefile: Done verifying installation of package $(package_name)"
	@echo "Makefile: Target $@ done."

.PHONY: build
build: _check_version $(bdist_file) $(sdist_file)
	@echo "Makefile: Target $@ done."

.PHONY: builddoc
builddoc: html
	@echo "Makefile: Target $@ done."

.PHONY: check
check: $(done_dir)/flake8_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: Target $@ done."

.PHONY: safety
safety: $(done_dir)/safety_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: Target $@ done."

.PHONY: pylint
pylint: $(done_dir)/pylint_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: Target $@ done."

.PHONY: mypy
mypy: $(done_dir)/mypy_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: Target $@ done."

.PHONY: all
all: develop check_reqs build builddoc check pylint mypy installtest test testdict doclinkcheck authors
	@echo "Makefile: Target $@ done."

.PHONY: clobber
clobber: clean
	@echo "Makefile: Removing everything for a fresh start"
	-$(call RM_FUNC,$(dist_files) $(dist_dir)/$(package_name)-$(package_version)*.egg $(package_name)/*cover)
	-$(call RM_R_FUNC,*.done)
	-$(call RMDIR_FUNC,$(doc_build_dir) .tox $(coverage_html_dir) $(package_name).egg-info)
	@echo "Makefile: Done removing everything for a fresh start"
	@echo "Makefile: Target $@ done."

.PHONY: clean
clean:
	@echo "Makefile: Removing temporary build products"
	-$(call RM_R_FUNC,*.pyc)
	-$(call RMDIR_R_FUNC,__pycache__)
	-$(call RM_R_FUNC,*~)
	-$(call RM_R_FUNC,.*~)
	-$(call RM_FUNC,MANIFEST parser.out .coverage $(package_name)/parser.out)
	-$(call RMDIR_FUNC,build .cache)
	@echo "Makefile: Done removing temporary build products"
	@echo "Makefile: Target $@ done."

.PHONY: upload
upload: _check_version $(dist_files)
	@echo "Makefile: Checking files before uploading to PyPI"
	twine check $(dist_files)
	@echo "Makefile: Uploading to PyPI: $(package_name) $(package_version)"
	twine upload $(dist_files)
	@echo "Makefile: Done uploading to PyPI"
	@echo "Makefile: Target $@ done."

.PHONY: html
html: $(done_dir)/develop_reqs_$(pymn)_$(PACKAGE_LEVEL).done $(doc_build_dir)/html/docs/index.html
	@echo "Makefile: Target $@ done."

# Boolean variable indicating that Sphinx should be run
# We run Sphinx only on Python>=3.8 because lower Python versions require too old Sphinx versions
run_sphinx := $(shell $(PYTHON_CMD) -c "import sys; py=sys.version_info[0:2]; sys.stdout.write('true' if py>=(3,8) else 'false')")

$(doc_build_dir)/html/docs/index.html: Makefile $(doc_dependent_files)
ifeq ($(run_sphinx),true)
	@echo "Makefile: Creating the documentation as HTML pages"
	-$(call RM_FUNC,$@)
	$(doc_cmd) -b html $(doc_opts) $(doc_build_dir)/html
	@echo "Makefile: Done creating the documentation as HTML pages; top level file: $@"
else
	@echo "Skipping Sphinx to create the documentation as HTML pages on Python version $(python_version)"
endif

.PHONY: pdf
pdf: $(done_dir)/develop_reqs_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(doc_dependent_files)
ifeq ($(run_sphinx),true)
	@echo "Makefile: Creating the documentation as PDF file"
	-$(call RM_FUNC,$@)
	$(doc_cmd) -b latex $(doc_opts) $(doc_build_dir)/pdf
	@echo "Makefile: Running LaTeX files through pdflatex..."
	$(MAKE) -C $(doc_build_dir)/pdf all-pdf
	@echo "Makefile: Done creating the documentation as PDF file in: $(doc_build_dir)/pdf/"
	@echo "Makefile: Target $@ done."
else
	@echo "Skipping Sphinx to create the documentation as PDF file on Python version $(python_version)"
endif

.PHONY: man
man: $(done_dir)/develop_reqs_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(doc_dependent_files)
ifeq ($(run_sphinx),true)
	@echo "Makefile: Creating the documentation as man pages"
	-$(call RM_FUNC,$@)
	$(doc_cmd) -b man $(doc_opts) $(doc_build_dir)/man
	@echo "Makefile: Done creating the documentation as man pages in: $(doc_build_dir)/man/"
	@echo "Makefile: Target $@ done."
else
	@echo "Skipping Sphinx to create the documentation as man pages on Python version $(python_version)"
endif

.PHONY: docchanges
docchanges: $(done_dir)/develop_reqs_$(pymn)_$(PACKAGE_LEVEL).done
ifeq ($(run_sphinx),true)
	@echo "Makefile: Creating the doc changes overview file"
	$(doc_cmd) -b changes $(doc_opts) $(doc_build_dir)/changes
	@echo
	@echo "Makefile: Done creating the doc changes overview file in: $(doc_build_dir)/changes/"
	@echo "Makefile: Target $@ done."
else
	@echo "Skipping Sphinx to create the doc changes overview file on Python version $(python_version)"
endif

.PHONY: doclinkcheck
doclinkcheck: $(done_dir)/develop_reqs_$(pymn)_$(PACKAGE_LEVEL).done
ifeq ($(run_sphinx),true)
	@echo "Makefile: Creating the doc link errors file"
	$(doc_cmd) -b linkcheck $(doc_opts) $(doc_build_dir)/linkcheck
	@echo
	@echo "Makefile: Done creating the doc link errors file: $(doc_build_dir)/linkcheck/output.txt"
	@echo "Makefile: Target $@ done."
else
	@echo "Skipping Sphinx to create the doc link errors file on Python version $(python_version)"
endif

.PHONY: doccoverage
doccoverage: $(done_dir)/develop_reqs_$(pymn)_$(PACKAGE_LEVEL).done
ifeq ($(run_sphinx),true)
	@echo "Makefile: Creating the doc coverage results file"
	$(doc_cmd) -b coverage $(doc_opts) $(doc_build_dir)/coverage
	@echo "Makefile: Done creating the doc coverage results file: $(doc_build_dir)/coverage/python.txt"
	@echo "Makefile: Target $@ done."
else
	@echo "Skipping Sphinx to create the doc coverage results file on Python version $(python_version)"
endif

.PHONY: authors
authors: _check_version original_authors.md
	echo "# Authors of this project" >AUTHORS.md
	echo "" >>AUTHORS.md
	cat original_authors.md >>AUTHORS.md
	echo "" >>AUTHORS.md
	echo "Sorted list of authors derived from git commit history:" >>AUTHORS.md
	echo '```' >>AUTHORS.md
	git shortlog --summary --email | cut -f 2 | sort >>AUTHORS.md
	echo '```' >>AUTHORS.md
	@echo '$@ done.'

# Note: distutils depends on the right files specified in MANIFEST.in, even when
# they are already specified e.g. in 'package_data' in setup.py.
# We generate the MANIFEST.in file automatically, to have a single point of
# control (this Makefile) for what gets into the distribution archive.
MANIFEST.in: Makefile $(dist_included_files)
	@echo "Makefile: Creating the manifest input file"
	echo "# MANIFEST.in file generated by Makefile - DO NOT EDIT!!" >$@
ifeq ($(PLATFORM),Windows_native)
	for %%f in ($(dist_included_files)) do (echo include %%f >>$@)
	echo recursive-include $(test_dir) * >>$@
	echo recursive-exclude $(test_dir) *.pyc >>$@
else
	echo "$(dist_included_files)" | xargs -n 1 echo include >>$@
	echo "recursive-include $(test_dir) *" >>$@
	echo "recursive-exclude $(test_dir) *.pyc" >>$@
endif
	@echo "Makefile: Done creating the manifest input file: $@"

# Distribution archives.
# Note: Deleting MANIFEST causes distutils (setup.py) to read MANIFEST.in and to
# regenerate MANIFEST. Otherwise, changes in MANIFEST.in will not be used.
# Note: Deleting build is a safeguard against picking up partial build products
# which can lead to incorrect hashbangs in scripts in wheel archives.
$(bdist_file) $(sdist_file): setup.py MANIFEST.in $(dist_included_files)
	@echo "Makefile: Creating the distribution archive files"
	-$(call RM_FUNC,MANIFEST)
	-$(call RMDIR_FUNC,build $(package_name).egg-info)
	$(PYTHON_CMD) setup.py sdist -d $(dist_dir) bdist_wheel -d $(dist_dir) --universal
	@echo "Makefile: Done creating the distribution archive files: $(bdist_file) $(sdist_file)"

$(done_dir)/pylint_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_reqs_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(pylint_rc_file) $(py_src_files)
	@echo "Makefile: Running Pylint"
	-$(call RM_FUNC,$@)
	pylint --version
	pylint $(pylint_opts) --rcfile=$(pylint_rc_file) $(py_src_files)
	echo "done" >$@
	@echo "Makefile: Done running Pylint"

$(done_dir)/mypy_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_reqs_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(py_src_files)
	@echo "Makefile: Running Mypy"
	-$(call RM_FUNC,$@)
	mypy --version
	mypy $(mypy_opts) $(py_src_files)
	echo "done" >$@
	@echo "Makefile: Done running Mypy"

$(done_dir)/flake8_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_reqs_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(flake8_rc_file) $(py_src_files)
	@echo "Makefile: Running Flake8"
	-$(call RM_FUNC,$@)
	flake8 --version
	flake8 --statistics --config=$(flake8_rc_file) --filename='*' $(py_src_files)
	echo "done" >$@
	@echo "Makefile: Done running Flake8"

$(done_dir)/safety_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_reqs_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(safety_policy_file) minimum-constraints.txt
ifeq ($(python_mn_version),3.6)
	@echo "Makefile: Warning: Skipping Safety on Python $(python_version)" >&2
else
	@echo "Makefile: Running pyup.io safety check"
	-$(call RM_FUNC,$@)
	safety check --policy-file $(safety_policy_file) -r minimum-constraints.txt --full-report
	echo "done" >$@
	@echo "Makefile: Done running pyup.io safety check"
endif

.PHONY: check_reqs
check_reqs: $(done_dir)/develop_reqs_$(pymn)_$(PACKAGE_LEVEL).done minimum-constraints.txt requirements.txt
	@echo "Makefile: Checking missing dependencies of the package"
	pip-missing-reqs $(package_name) --requirements-file=requirements.txt
	pip-missing-reqs $(package_name) --requirements-file=minimum-constraints.txt
	@echo "Makefile: Done checking missing dependencies of the package"
ifeq ($(PLATFORM),Windows_native)
# Reason for skipping on Windows is https://github.com/r1chardj0n3s/pip-check-reqs/issues/67
	@echo "Makefile: Warning: Skipping the checking of missing dependencies of site-packages directory on native Windows" >&2
else
	@echo "Makefile: Checking missing dependencies of some development packages"
	@rc=0; for pkg in $(check_reqs_packages); do dir=$$($(PYTHON_CMD) -c "import $${pkg} as m,os; dm=os.path.dirname(m.__file__); d=dm if not dm.endswith('site-packages') else m.__file__; print(d)"); cmd="pip-missing-reqs $${dir} --requirements-file=minimum-constraints.txt"; echo $${cmd}; $${cmd}; rc=$$(expr $${rc} + $${?}); done; exit $${rc}
	@echo "Makefile: Done checking missing dependencies of some development packages"
endif
	@echo "Makefile: $@ done."

ifdef TEST_INSTALLED
  test_deps =
else
  test_deps = develop
endif

.PHONY: test
test: $(test_deps)
	@echo "Makefile: Running unit tests"
	py.test --color=yes $(pytest_cov_opts) $(pytest_warning_opts) $(pytest_opts) $(test_dir)/unittest -s
	@echo "Makefile: Done running unit tests"

.PHONY: testdict
testdict: $(test_deps)
	@echo "Makefile: Running unit tests against standard dict"
ifeq ($(PLATFORM),Windows_native)
	cmd /c "set TEST_DICT=1 & py.test --color=yes $(pytest_warning_opts) $(pytest_opts) $(test_dir)/unittest -s"
else
	TEST_DICT=1 py.test --color=yes $(pytest_warning_opts) $(pytest_opts) $(test_dir)/unittest -s
endif
	@echo "Makefile: Done running unit tests against standard dict"

.PHONY: installtest
installtest: $(bdist_file) $(sdist_file) $(test_dir)/installtest/test_install.sh
	@echo "Makefile: Running install tests"
ifeq ($(PLATFORM),Windows_native)
	@echo "Makefile: Warning: Skipping install test on native Windows" >&2
else
	$(test_dir)/installtest/test_install.sh $(bdist_file) $(sdist_file) $(PYTHON_CMD)
endif
	@echo "Makefile: Done running install tests"
