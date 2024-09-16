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
  pip_level_opts := -c minimum-constraints-develop.txt -c minimum-constraints-install.txt
else
  ifeq ($(PACKAGE_LEVEL),latest)
    pip_level_opts := --upgrade --upgrade-strategy eager
  else
    $(error Error: Invalid value for PACKAGE_LEVEL variable: $(PACKAGE_LEVEL))
  endif
endif

ifndef RUN_TYPE
  RUN_TYPE := local
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

# Package version (e.g. "1.8.0a1.dev10+gd013028e" during development, or "1.8.0"
# when releasing).
# Note: The package version is automatically calculated by setuptools_scm based
# on the most recent tag in the commit history, increasing the least significant
# version indicator by 1.
package_version := $(shell $(PYTHON_CMD) -m setuptools_scm)

# The version file is recreated by setuptools-scm on every build, so it is
# excluuded from git, and also from some dependency lists.
version_file := $(package_name)/_version_scm.py

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
bdist_file = $(dist_dir)/$(package_name)-$(package_version)-py3-none-any.whl
sdist_file = $(dist_dir)/$(package_name)-$(package_version).tar.gz

dist_files = $(bdist_file) $(sdist_file)

# Source files in the packages
package_py_files := \
    $(filter-out $(version_file), $(wildcard $(package_name)/*.py)) \
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
    $(package_py_files) \
    $(version_file) \

# PyLint config file
pylint_rc_file := pylintrc

# PyLint additional options
pylint_opts := --disable=fixme

# Mypy options
mypy_opts := --follow-imports skip

# Flake8 config file
flake8_rc_file := .flake8

# Safety policy files
safety_install_policy_file := .safety-policy-install.yml
safety_develop_policy_file := .safety-policy-develop.yml

# Test root directory
test_dir := tests

# Unit test directory and files
test_unit_dir := $(test_dir)/unittest
test_unit_py_files := \
    $(wildcard $(test_unit_dir)/*.py) \
    $(wildcard $(test_unit_dir)/*/*.py) \
    $(wildcard $(test_unit_dir)/*/*/*.py) \

# Install test directory
test_install_dir := $(test_dir)/installtest

# Source files for check with PyLint and Flake8
check_py_files := \
    $(package_py_files) \
    $(test_unit_py_files) \
    $(doc_dir)/conf.py \

# Source files for check with MyPy
check_mypy_py_files := \
    $(package_py_files) \
    $(test_unit_py_files) \

ifdef TESTCASES
  pytest_opts := $(TESTOPTS) -k $(TESTCASES)
else
  pytest_opts := $(TESTOPTS)
endif
pytest_warning_opts := -W default -W ignore::PendingDeprecationWarning -W ignore::ResourceWarning
pytest_cov_opts := --cov $(package_name) $(coverage_report) --cov-config .coveragerc

# Files the distribution archives depend upon.
dist_dependent_files := \
    pyproject.toml \
    LICENSE \
    README.md \
    INSTALL.md \
    requirements.txt \
    $(package_py_files) \

# Directory for .done files
done_dir := done

# Packages whose dependencies are checked using pip-missing-reqs
check_reqs_packages := pytest coverage coveralls flake8 pylint twine safety sphinx

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
	@echo "  test       - Run unit testss against local package"
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
	@echo "  TEST_DICT - When non-empty, run unit tests against the standard dict."
	@echo "  PACKAGE_LEVEL - Package level to be used for installing dependent Python"
	@echo "      packages in 'install' and 'develop' targets:"
	@echo "        latest - Latest package versions available on Pypi"
	@echo "        minimum - A minimum version as defined in minimum-constraints-*.txt"
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
	@echo "Makefile: $@ done."

.PHONY: _always
_always:

.PHONY: pip_list
pip_list:
	@echo "Makefile: Installed Python packages:"
	$(PIP_CMD) $(pip_opts) list
	@echo "Makefile: $@ done."

.PHONY: env
env:
	@echo "Makefile: Environment as seen by make:"
	$(ENV)
	@echo "Makefile: $@ done."

.PHONY: install
install: $(done_dir)/install_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

.PHONY: develop
develop: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

.PHONY: build
build: $(dist_files)
	@echo "Makefile: $@ done."

.PHONY: builddoc
builddoc: $(doc_build_dir)/html/docs/index.html
	@echo "Makefile: $@ done."

.PHONY: check
check: $(done_dir)/flake8_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

.PHONY: check_reqs
check_reqs: $(done_dir)/check_reqs_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

.PHONY: safety
safety: $(done_dir)/safety_develop_$(pymn)_$(PACKAGE_LEVEL).done $(done_dir)/safety_install_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

.PHONY: pylint
pylint: $(done_dir)/pylint_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

.PHONY: mypy
mypy: $(done_dir)/mypy_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

.PHONY: all
all: develop check_reqs build builddoc check pylint mypy installtest test testdict doclinkcheck authors
	@echo "Makefile: $@ done."

.PHONY: clobber
clobber: clean
	@echo "Makefile: Removing everything for a fresh start"
	-$(call RM_FUNC,$(dist_files) $(dist_dir)/$(package_name)-$(package_version)*.egg $(package_name)/*cover)
	-$(call RM_R_FUNC,*.done)
	-$(call RMDIR_FUNC,$(doc_build_dir) .tox $(coverage_html_dir) $(package_name).egg-info)
	@echo "Makefile: Done removing everything for a fresh start"
	@echo "Makefile: $@ done."

.PHONY: clean
clean:
	@echo "Makefile: Removing temporary build products"
	-$(call RM_R_FUNC,*.pyc)
	-$(call RMDIR_R_FUNC,__pycache__)
	-$(call RM_R_FUNC,*~)
	-$(call RM_R_FUNC,.*~)
	-$(call RM_FUNC,MANIFEST MANIFEST.in parser.out .coverage $(package_name)/parser.out)
	-$(call RMDIR_FUNC,build .cache)
	@echo "Makefile: Done removing temporary build products"
	@echo "Makefile: $@ done."

.PHONY: upload
upload: $(dist_files)
	@echo "Makefile: Checking files before uploading to PyPI"
	twine check $(dist_files)
	@echo "Makefile: Uploading to PyPI: $(package_name) $(package_version)"
	twine upload $(dist_files)
	@echo "Makefile: Done uploading to PyPI"
	@echo "Makefile: $@ done."

$(done_dir)/base_$(pymn)_$(PACKAGE_LEVEL).done: Makefile base-requirements.txt minimum-constraints-develop.txt minimum-constraints-install.txt
	-$(call RM_FUNC,$@)
	@echo "Makefile: Installing/upgrading base packages with PACKAGE_LEVEL=$(PACKAGE_LEVEL)"
	$(PYTHON_CMD) -m pip install $(pip_level_opts) -r base-requirements.txt
	@echo "Makefile: Done installing/upgrading base packages"
	echo "done" >$@

$(done_dir)/install_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/base_$(pymn)_$(PACKAGE_LEVEL).done Makefile requirements.txt minimum-constraints-develop.txt minimum-constraints-install.txt $(package_py_files)
	-$(call RM_FUNC,$@)
	@echo "Installing $(package_name) (non-editable) and runtime reqs with PACKAGE_LEVEL=$(PACKAGE_LEVEL)"
	$(PYTHON_CMD) -m pip install $(pip_level_opts) $(pip_level_opts_new) .
	$(PYTHON_CMD) -c "import $(package_name); print('ok')"
	@echo "Makefile: Done installing Python installation prerequisites"
	echo "done" >$@

$(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/base_$(pymn)_$(PACKAGE_LEVEL).done Makefile dev-requirements.txt minimum-constraints-develop.txt minimum-constraints-install.txt
	-$(call RM_FUNC,$@)
	@echo "Makefile: Installing development requirements (with PACKAGE_LEVEL=$(PACKAGE_LEVEL))"
	$(PIP_CMD_MOD) $(pip_opts) install $(pip_level_opts) -r dev-requirements.txt
	@echo "Makefile: Done installing development requirements"
	echo "done" >$@

$(doc_build_dir)/html/docs/index.html: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(doc_dependent_files)
	-$(call RM_FUNC,$@)
	@echo "Makefile: Creating the documentation as HTML pages"
	$(doc_cmd) -b html $(doc_opts) $(doc_build_dir)/html
	@echo "Makefile: Done creating the documentation as HTML pages; top level file: $@"

.PHONY: pdf
pdf: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(doc_dependent_files)
	-$(call RM_FUNC,$@)
	@echo "Makefile: Creating the documentation as PDF file"
	$(doc_cmd) -b latex $(doc_opts) $(doc_build_dir)/pdf
	@echo "Makefile: Running LaTeX files through pdflatex..."
	$(MAKE) -C $(doc_build_dir)/pdf all-pdf
	@echo "Makefile: Done creating the documentation as PDF file in: $(doc_build_dir)/pdf/"
	@echo "Makefile: $@ done."

.PHONY: man
man: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(doc_dependent_files)
	-$(call RM_FUNC,$@)
	@echo "Makefile: Creating the documentation as man pages"
	$(doc_cmd) -b man $(doc_opts) $(doc_build_dir)/man
	@echo "Makefile: Done creating the documentation as man pages in: $(doc_build_dir)/man/"
	@echo "Makefile: $@ done."

.PHONY: docchanges
docchanges: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: Creating the doc changes overview file"
	$(doc_cmd) -b changes $(doc_opts) $(doc_build_dir)/changes
	@echo
	@echo "Makefile: Done creating the doc changes overview file in: $(doc_build_dir)/changes/"
	@echo "Makefile: $@ done."

.PHONY: doclinkcheck
doclinkcheck: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: Creating the doc link errors file"
	$(doc_cmd) -b linkcheck $(doc_opts) $(doc_build_dir)/linkcheck
	@echo
	@echo "Makefile: Done creating the doc link errors file: $(doc_build_dir)/linkcheck/output.txt"
	@echo "Makefile: $@ done."

.PHONY: doccoverage
doccoverage: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: Creating the doc coverage results file"
	$(doc_cmd) -b coverage $(doc_opts) $(doc_build_dir)/coverage
	@echo "Makefile: Done creating the doc coverage results file: $(doc_build_dir)/coverage/python.txt"
	@echo "Makefile: $@ done."

.PHONY: authors
authors: AUTHORS.md
	@echo "Makefile: $@ done."

# Make sure the AUTHORS.md file is up to date but has the old date when it did not change to prevent redoing dependent targets
AUTHORS.md: _always original_authors.md
	echo "# Authors of this project" >AUTHORS.md.tmp
	echo "" >>AUTHORS.md.tmp
	cat original_authors.md >>AUTHORS.md.tmp
	echo "" >>AUTHORS.md.tmp
	echo "Sorted list of authors derived from git commit history:" >>AUTHORS.md.tmp
	echo '```' >>AUTHORS.md.tmp
	git shortlog --summary --email | cut -f 2 | sort >>AUTHORS.md.tmp
	echo '```' >>AUTHORS.md.tmp
	sh -c "if ! diff -q AUTHORS.md.tmp AUTHORS.md; then mv AUTHORS.md.tmp AUTHORS.md; else rm AUTHORS.md.tmp; fi"

$(sdist_file): pyproject.toml $(dist_dependent_files)
	@echo "Makefile: Building the source distribution archive: $(sdist_file)"
	$(PYTHON_CMD) -m build --sdist --outdir $(dist_dir) .
	@echo "Makefile: Done building the source distribution archive: $(sdist_file)"

$(bdist_file) $(version_file): pyproject.toml $(dist_dependent_files)
	@echo "Makefile: Building the wheel distribution archive: $(bdist_file)"
	$(PYTHON_CMD) -m build --wheel --outdir $(dist_dir) -C--universal .
	@echo "Makefile: Done building the wheel distribution archive: $(bdist_file)"

$(done_dir)/flake8_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(flake8_rc_file) $(check_py_files)
	-$(call RM_FUNC,$@)
	@echo "Makefile: Running Flake8"
	flake8 --version
	flake8 --statistics --config=$(flake8_rc_file) --filename='*' $(check_py_files)
	@echo "Makefile: Done running Flake8"
	echo "done" >$@

$(done_dir)/pylint_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(pylint_rc_file) $(check_py_files)
	-$(call RM_FUNC,$@)
	@echo "Makefile: Running Pylint"
	pylint --version
	pylint $(pylint_opts) --rcfile=$(pylint_rc_file) $(check_py_files)
	@echo "Makefile: Done running Pylint"
	echo "done" >$@

$(done_dir)/mypy_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(check_mypy_py_files)
	-$(call RM_FUNC,$@)
	@echo "Makefile: Running Mypy"
	mypy --version
	mypy $(mypy_opts) $(check_mypy_py_files)
	@echo "Makefile: Done running Mypy"
	echo "done" >$@

$(done_dir)/safety_develop_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done $(safety_develop_policy_file) minimum-constraints-develop.txt minimum-constraints-install.txt
	-$(call RM_FUNC,$@)
	@echo "Makefile: Running Safety for development packages (and tolerate safety issues when RUN_TYPE is normal or scheduled)"
	bash -c "safety check --policy-file $(safety_develop_policy_file) -r minimum-constraints-develop.txt --full-report || test '$(RUN_TYPE)' == 'normal' || test '$(RUN_TYPE)' == 'scheduled' || exit 1"
	@echo "Makefile: Done running Safety for development packages"
	echo "done" >$@

$(done_dir)/safety_install_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done $(safety_install_policy_file) minimum-constraints-install.txt
	-$(call RM_FUNC,$@)
	@echo "Makefile: Running Safety for install packages (and tolerate safety issues when RUN_TYPE is normal)"
	bash -c "safety check --policy-file $(safety_install_policy_file) -r minimum-constraints-install.txt --full-report || test '$(RUN_TYPE)' == 'normal' || exit 1"
	@echo "Makefile: Done running Safety for install packages"
	echo "done" >$@

$(done_dir)/check_reqs_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done minimum-constraints-develop.txt minimum-constraints-install.txt requirements.txt
	@echo "Makefile: Checking missing dependencies of the package"
	pip-missing-reqs $(package_name) --requirements-file=requirements.txt
	pip-missing-reqs $(package_name) --requirements-file=minimum-constraints-install.txt
	@echo "Makefile: Done checking missing dependencies of the package"
ifeq ($(PLATFORM),Windows_native)
# Reason for skipping on Windows is https://github.com/r1chardj0n3s/pip-check-reqs/issues/67
	@echo "Makefile: Warning: Skipping the checking of missing dependencies of site-packages directory on native Windows" >&2
else
	@echo "Makefile: Checking missing dependencies of some development packages"
	cat minimum-constraints-develop.txt minimum-constraints-install.txt >tmp_minimum-constraints.txt
	@rc=0; for pkg in $(check_reqs_packages); do dir=$$($(PYTHON_CMD) -c "import $${pkg} as m,os; dm=os.path.dirname(m.__file__); d=dm if not dm.endswith('site-packages') else m.__file__; print(d)"); cmd="pip-missing-reqs $${dir} --requirements-file=tmp_minimum-constraints.txt"; echo $${cmd}; $${cmd}; rc=$$(expr $${rc} + $${?}); done; exit $${rc}
	rm -f tmp_minimum-constraints.txt
	@echo "Makefile: Done checking missing dependencies of some development packages"
endif
	echo "done" >$@

.PHONY: test
test: $(test_unit_py_files)
	@echo "Makefile: Running unit tests on local package"
	py.test --color=yes $(pytest_cov_opts) $(pytest_warning_opts) $(pytest_opts) $(test_unit_dir) -s
	@echo "Makefile: Done running unit tests"

.PHONY: testdict
testdict: $(test_unit_py_files)
	@echo "Makefile: Running unit tests against standard dict"
ifeq ($(PLATFORM),Windows_native)
	cmd /c "set TEST_DICT=1 & py.test --color=yes $(pytest_warning_opts) $(pytest_opts) $(test_unit_dir) -s"
else
	TEST_DICT=1 py.test --color=yes $(pytest_warning_opts) $(pytest_opts) $(test_unit_dir) -s
endif
	@echo "Makefile: Done running unit tests against standard dict"

.PHONY: installtest
installtest: $(bdist_file) $(sdist_file) $(test_install_dir)/test_install.sh
	@echo "Makefile: Running install tests"
ifeq ($(PLATFORM),Windows_native)
	@echo "Makefile: Warning: Skipping install test on native Windows" >&2
else
	$(test_install_dir)/test_install.sh $(bdist_file) $(sdist_file) $(PYTHON_CMD)
endif
	@echo "Makefile: Done running install tests"
