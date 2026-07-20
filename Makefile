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

# Determine OS platform make runs on.
ifeq ($(OS),Windows_NT)
  ifdef PWD
    PLATFORM := Windows_UNIX
    SHELL := $(shell which bash)
  else
    PLATFORM := Windows_native
    SHELL := wsl bash
  endif
  .SHELLFLAGS := -c
else
  # Values: Linux, Darwin
  PLATFORM := $(shell uname -s)
  SHELL := $(shell which bash)
  .SHELLFLAGS := -c
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
package_version := $(shell $(PYTHON_CMD) -m setuptools_scm 2>/dev/null)

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

.PHONY: help
help:
	@echo "Makefile for $(project_name) project"
	@echo "$(package_name) package version: $(package_version)"
	@echo ""
	@echo "Make targets:"
	@echo "  check_reqs_prepare - Prepare dependency checks (must be run before install)"
	@echo "  install    - Install $(package_name) as standalone and its dependent packages"
	@echo "  check_reqs_install - Perform missing install dependency checks (must be run before develop)"
	@echo "  develop    - Set up development of $(project_name) project (installs $(package_name) as editable)"
	@echo "  check_reqs - Perform missing dependency checks (must be run after develop)"
	@echo "  build      - Build the distribution archive files in: $(dist_dir)"
	@echo "  builddoc   - Build documentation in: $(doc_build_dir)"
	@echo "  check      - Run Flake8 on Python sources"
	@echo "  pylint     - Run PyLint on Python sources"
	@echo "  mypy       - Run Mypy on Python sources"
	@echo "  safety     - Run safety on Python sources"
	@echo "  installtest - Run install tests"
	@echo "  test       - Run unit testss against local package"
	@echo "  testdict   - Run unit tests against standard dict"
	@echo "  doclinkcheck - Run Sphinx linkcheck on the documentation"
	@echo "  authors    - Generate AUTHORS.md file from git log"
	@echo "  all        - Do all of the above"
	@echo "  release_branch - Create a release branch when releasing a version (requires VERSION and optionally BRANCH to be set)"
	@echo "  release_publish - Publish to PyPI when releasing a version (requires VERSION and optionally BRANCH to be set)"
	@echo "  start_branch - Create a start branch when starting a new version (requires VERSION and optionally BRANCH to be set)"
	@echo "  start_tag - Create a start tag when starting a new version (requires VERSION and optionally BRANCH to be set)"
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
	@echo "  VERSION=... - M.N.U version to be released or started"
	@echo "  BRANCH=... - Name of branch to be released or started (default is derived from VERSION)"

.PHONY: platform
platform:
	@echo "Makefile: Platform related information as seen by make:"
	@echo "Platform: $(PLATFORM)"
	@echo "Shell used for commands: $(SHELL)"
	@echo "Shell flags: $(.SHELLFLAGS)"
	@echo "Make command location: $(MAKE)"
	@echo "Make version: $(MAKE_VERSION)"
	@echo "Python command name: $(PYTHON_CMD)"
	@echo "Python command location: $(shell which $(PYTHON_CMD))"
	@echo "Python version: $(python_full_version)"
	@echo "Python bit size: $(python_bitsize)"
	@echo "Pip command name: $(PIP_CMD)"
	@echo "Pip command location: $(shell which $(PIP_CMD))"
	@echo "Package $(package_name) version: $(package_version)"
	@echo "Package $(package_name) installation: $(shell $(PIP_CMD) $(pip_opts) show $(package_name) | grep Location)"
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
	env | sort
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

.PHONY: pylint
pylint: $(done_dir)/pylint_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

.PHONY: mypy
mypy: $(done_dir)/mypy_$(pymn)_$(PACKAGE_LEVEL).done
	@echo "Makefile: $@ done."

.PHONY: all
all: install develop check_reqs build builddoc check pylint mypy installtest test testdict doclinkcheck authors
	@echo "Makefile: $@ done."

.PHONY: release_branch
release_branch:
	@if [ -z "$(VERSION)" ]; then echo ""; echo "Error: VERSION env var is not set"; echo ""; false; fi
	@if [ -n "$$(git status -s)" ]; then echo ""; echo "Error: Local git repo has uncommitted files:"; echo ""; git status; false; fi
	git fetch origin
	@if [ -z "$$(git tag -l $(VERSION)a0)" ]; then echo ""; echo "Error: Release start tag $(VERSION)a0 does not exist (the version has not been started)"; echo ""; false; fi
	@if [ -n "$$(git tag -l $(VERSION))" ]; then echo ""; echo "Error: Release tag $(VERSION) already exists (the version has already been released)"; echo ""; false; fi
	@if [[ -n "$${BRANCH}" ]]; then echo $${BRANCH} >branch.tmp; elif [[ "$${VERSION#*.*.}" == "0" ]]; then echo "master" >branch.tmp; else echo "stable_$${VERSION%.*}" >branch.tmp; fi
	@if [ -z "$$(git branch --contains $(VERSION)a0 $$(cat branch.tmp))" ]; then echo ""; echo "Error: Release start tag $(VERSION)a0 is not in target branch $$(cat branch.tmp), but in:"; echo ""; git branch --contains $(VERSION)a0;. false; fi
	@echo "==> This will start the release of $(package_name) version $(VERSION) to PyPI using target branch $$(cat branch.tmp)"
	@echo -n '==> Continue? [yN] '
	@read answer; if [ "$$answer" != "y" ]; then echo "Aborted."; false; fi
	git checkout $$(cat branch.tmp)
	git pull
	@if [ -z "$$(git branch -l release_$(VERSION))" ]; then echo "Creating release branch release_$(VERSION)"; git checkout -b release_$(VERSION); fi
	git checkout release_$(VERSION)
	make authors
	towncrier build --version $(VERSION) --yes
	@if ls changes/*.rst >/dev/null 2>/dev/null; then echo ""; echo "Error: There are incorrectly named change fragment files that towncrier did not use:"; ls -1 changes/*.rst; echo ""; false; fi
	git commit -asm "Release $(VERSION)"
	git push --set-upstream origin release_$(VERSION)
	rm -f branch.tmp
	@echo "Done: Pushed the release branch to GitHub - now go there and create a PR."
	@echo "Makefile: $@ done."

.PHONY: release_publish
release_publish:
	@if [ -z "$(VERSION)" ]; then echo ""; echo "Error: VERSION env var is not set"; echo ""; false; fi
	@if [ -n "$$(git status -s)" ]; then echo ""; echo "Error: Local git repo has uncommitted files:"; echo ""; git status; false; fi
	git fetch origin
	@if [ -n "$$(git tag -l $(VERSION))" ]; then echo ""; echo "Error: Release tag $(VERSION) already exists (the version has already been released)"; echo ""; false; fi
	@if [[ -n "$${BRANCH}" ]]; then echo $${BRANCH} >branch.tmp; elif [[ "$${VERSION#*.*.}" == "0" ]]; then echo "master" >branch.tmp; else echo "stable_$${VERSION%.*}" >branch.tmp; fi
	@if ! git show-ref --quiet refs/remotes/origin/$$(cat branch.tmp); then echo ""; echo "Error: Branch origin/$$(cat branch.tmp) does not exist. Incorrect VERSION env var?"; echo ""; false; fi
	@if [[ ! $$(git log --format=format:%s origin/$$(cat branch.tmp)~..origin/$$(cat branch.tmp)) =~ ^Release\ $(VERSION) ]]; then echo ""; echo "Error: Release PR for $(VERSION) has not been merged yet"; echo ""; false; fi
	@echo "==> This will publish $(package_name) version $(VERSION) to PyPI using target branch $$(cat branch.tmp)"
	@echo -n '==> Continue? [yN] '
	@read answer; if [ "$$answer" != "y" ]; then echo "Aborted."; false; fi
	git checkout $$(cat branch.tmp)
	git pull
	git tag -f $(VERSION)
	git push -f --tags
	-git branch -D release_$(VERSION)
	-git branch -D -r origin/release_$(VERSION)
	rm -f branch.tmp
	@echo "Done: Triggered the publish workflow - now wait for it to finish and verify the publishing."
	@echo "Makefile: $@ done."

.PHONY: start_branch
start_branch:
	@if [ -z "$(VERSION)" ]; then echo ""; echo "Error: VERSION env var is not set"; echo ""; false; fi
	@if [ -n "$$(git status -s)" ]; then echo ""; echo "Error: Local git repo has uncommitted files:"; echo ""; git status; false; fi
	git fetch origin
	@if [ -n "$$(git tag -l $(VERSION))" ]; then echo ""; echo "Error: Release tag $(VERSION) already exists (the version has already been released)"; echo ""; false; fi
	@if [ -n "$$(git tag -l $(VERSION)a0)" ]; then echo ""; echo "Error: Release start tag $(VERSION)a0 already exists (the new version has alreay been started)"; echo ""; false; fi
	@if [ -n "$$(git branch -l start_$(VERSION))" ]; then echo ""; echo "Error: Start branch start_$(VERSION) already exists (the start of the new version is already underway)"; echo ""; false; fi
	@if [[ -n "$${BRANCH}" ]]; then echo $${BRANCH} >branch.tmp; elif [[ "$${VERSION#*.*.}" == "0" ]]; then echo "master" >branch.tmp; else echo "stable_$${VERSION%.*}" >branch.tmp; fi
	@echo "==> This will start new version $(VERSION) using target branch $$(cat branch.tmp)"
	@echo -n '==> Continue? [yN] '
	@read answer; if [ "$$answer" != "y" ]; then echo "Aborted."; false; fi
	git checkout $$(cat branch.tmp)
	git pull
	git checkout -b start_$(VERSION)
	echo "Dummy change for starting new version $(VERSION)" >changes/noissue.$(VERSION).notshown.rst
	git add changes/noissue.$(VERSION).notshown.rst
	git commit -asm "Start $(VERSION)"
	git push --set-upstream origin start_$(VERSION)
	rm -f branch.tmp
	@echo "Done: Pushed the start branch to GitHub - now go there and create a PR."
	@echo "Makefile: $@ done."

.PHONY: start_tag
start_tag:
	@if [ -z "$(VERSION)" ]; then echo ""; echo "Error: VERSION env var is not set"; echo ""; false; fi
	@if [ -n "$$(git status -s)" ]; then echo ""; echo "Error: Local git repo has uncommitted files:"; echo ""; git status; false; fi
	git fetch origin
	@if [ -n "$$(git tag -l $(VERSION)a0)" ]; then echo ""; echo "Error: Release start tag $(VERSION)a0 already exists (the new version has alreay been started)"; echo ""; false; fi
	@if [[ -n "$${BRANCH}" ]]; then echo $${BRANCH} >branch.tmp; elif [[ "$${VERSION#*.*.}" == "0" ]]; then echo "master" >branch.tmp; else echo "stable_$${VERSION%.*}" >branch.tmp; fi
	@if ! git show-ref --quiet refs/remotes/origin/$$(cat branch.tmp); then echo ""; echo "Error: Branch origin/$$(cat branch.tmp) does not exist. Incorrect VERSION env var?"; echo ""; false; fi
	@if [[ ! $$(git log --format=format:%s origin/$$(cat branch.tmp)~..origin/$$(cat branch.tmp)) =~ ^Start\ $(VERSION) ]]; then echo ""; echo "Error: Start PR for $(VERSION) has not been merged yet"; echo ""; false; fi
	@echo "==> This will complete the start of new version $(VERSION) using target branch $$(cat branch.tmp)"
	@echo -n '==> Continue? [yN] '
	@read answer; if [ "$$answer" != "y" ]; then echo "Aborted."; false; fi
	git checkout $$(cat branch.tmp)
	git pull
	git tag -f $(VERSION)a0
	git push -f --tags
	-git branch -D start_$(VERSION)
	-git branch -D -r origin/start_$(VERSION)
	rm -f branch.tmp
	@echo "Done: Pushed the release start tag and cleaned up the release start branch."
	@echo "Makefile: $@ done."

.PHONY: clobber
clobber: clean
	@echo "Makefile: Removing everything for a fresh start"
	rm -f $(dist_files) $(dist_dir)/$(package_name)-$(package_version)*.egg $(package_name)/*cover
	find . -type f -name '*.done' -delete
	rm -rf $(doc_build_dir) .tox $(coverage_html_dir) $(package_name).egg-info
	@echo "Makefile: Done removing everything for a fresh start"
	@echo "Makefile: $@ done."

.PHONY: clean
clean:
	@echo "Makefile: Removing temporary build products"
	find . -type f -name '*.pyc' -delete
	find . -type d -name '__pycache__' | xargs -n 1 rm -rf
	find . -type f -name '*~' -delete
	find . -type f -name '.*~' -delete
	rm -f MANIFEST MANIFEST.in parser.out .coverage $(package_name)/parser.out
	rm -rf build .cache
	@echo "Makefile: Done removing temporary build products"
	@echo "Makefile: $@ done."

$(done_dir)/base_$(pymn)_$(PACKAGE_LEVEL).done: Makefile base-requirements.txt minimum-constraints-develop.txt minimum-constraints-install.txt
	rm -f $@
	@echo "Makefile: Installing/upgrading base packages with PACKAGE_LEVEL=$(PACKAGE_LEVEL)"
	$(PYTHON_CMD) -m pip install $(pip_level_opts) -r base-requirements.txt
	@echo "Makefile: Done installing/upgrading base packages"
	echo "done" >$@

$(done_dir)/install_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/base_$(pymn)_$(PACKAGE_LEVEL).done Makefile requirements.txt minimum-constraints-develop.txt minimum-constraints-install.txt $(package_py_files)
	rm -f $@
	@echo "Installing $(package_name) (non-editable) and runtime reqs with PACKAGE_LEVEL=$(PACKAGE_LEVEL)"
	$(PYTHON_CMD) -m pip install $(pip_level_opts) $(pip_level_opts_new) .
	$(PYTHON_CMD) -c "import $(package_name); print('ok')"
	@echo "Makefile: Done installing Python installation prerequisites"
	echo "done" >$@

$(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/base_$(pymn)_$(PACKAGE_LEVEL).done Makefile dev-requirements.txt minimum-constraints-develop.txt minimum-constraints-install.txt
	rm -f $@
	@echo "Makefile: Installing development requirements (with PACKAGE_LEVEL=$(PACKAGE_LEVEL))"
	$(PIP_CMD) $(pip_opts) install $(pip_level_opts) -r dev-requirements.txt
	@echo "Makefile: Done installing development requirements"
	echo "done" >$@

$(doc_build_dir)/html/docs/index.html: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(doc_dependent_files)
	rm -f $@
	@echo "Makefile: Creating the documentation as HTML pages"
	$(doc_cmd) -b html $(doc_opts) $(doc_build_dir)/html
	@echo "Makefile: Done creating the documentation as HTML pages; top level file: $@"

.PHONY: pdf
pdf: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(doc_dependent_files)
	rm -f $@
	@echo "Makefile: Creating the documentation as PDF file"
	$(doc_cmd) -b latex $(doc_opts) $(doc_build_dir)/pdf
	@echo "Makefile: Running LaTeX files through pdflatex..."
	$(MAKE) -C $(doc_build_dir)/pdf all-pdf
	@echo "Makefile: Done creating the documentation as PDF file in: $(doc_build_dir)/pdf/"
	@echo "Makefile: $@ done."

.PHONY: man
man: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(doc_dependent_files)
	rm -f $@
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
	-$(doc_cmd) -b linkcheck $(doc_opts) $(doc_build_dir)/linkcheck
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

# Make sure the AUTHORS.md file is up to date but has the old date when it did
# not change to prevent redoing dependent targets.
AUTHORS.md: _always
	echo "# Authors of this project" >AUTHORS.md.tmp
	echo "" >>AUTHORS.md.tmp
	echo "Sorted list of authors derived from git commit history:" >>AUTHORS.md.tmp
	echo '```' >>AUTHORS.md.tmp
	git shortlog --summary --email HEAD | cut -f 2 | LC_ALL=C.UTF-8 sort >>AUTHORS.md.tmp
	echo '```' >>AUTHORS.md.tmp
	if ! diff -q AUTHORS.md.tmp AUTHORS.md; then echo 'Updating AUTHORS.md as follows:'; diff AUTHORS.md.tmp AUTHORS.md; mv AUTHORS.md.tmp AUTHORS.md; else echo 'AUTHORS.md was already up to date'; rm AUTHORS.md.tmp; fi

$(sdist_file): pyproject.toml $(dist_dependent_files)
	@echo "Makefile: Building the source distribution archive: $(sdist_file)"
	$(PYTHON_CMD) -m build --no-isolation --sdist --outdir $(dist_dir) .
	ls -l $(sdist_file) || ls -l $(dist_dir) && echo package_level=$(package_level) && $(PYTHON_CMD) -m setuptools_scm
	@echo "Makefile: Done building the source distribution archive: $(sdist_file)"

$(bdist_file) $(version_file): pyproject.toml $(dist_dependent_files)
	@echo "Makefile: Building the wheel distribution archive: $(bdist_file)"
	$(PYTHON_CMD) -m build --no-isolation --wheel --outdir $(dist_dir) -C--universal .
	ls -l $(bdist_file) $(version_file) || ls -l $(dist_dir) && echo package_level=$(package_level) && $(PYTHON_CMD) -m setuptools_scm
	@echo "Makefile: Done building the wheel distribution archive: $(bdist_file)"

$(done_dir)/flake8_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(flake8_rc_file) $(check_py_files)
	rm -f $@
	@echo "Makefile: Running Flake8"
	flake8 --version
	flake8 --statistics --config=$(flake8_rc_file) --filename='*' $(check_py_files)
	@echo "Makefile: Done running Flake8"
	echo "done" >$@

$(done_dir)/pylint_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(pylint_rc_file) $(check_py_files)
	rm -f $@
	@echo "Makefile: Running Pylint"
	pylint --version
	pylint $(pylint_opts) --rcfile=$(pylint_rc_file) $(check_py_files)
	@echo "Makefile: Done running Pylint"
	echo "done" >$@

$(done_dir)/mypy_$(pymn)_$(PACKAGE_LEVEL).done: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(check_mypy_py_files)
	rm -f $@
	@echo "Makefile: Running Mypy"
	mypy --version
	mypy $(mypy_opts) $(check_mypy_py_files)
	@echo "Makefile: Done running Mypy"
	echo "done" >$@

.PHONY: safety
safety: $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done Makefile $(safety_develop_policy_file) $(safety_install_policy_file) minimum-constraints-develop.txt minimum-constraints-install.txt minimum-constraints-install.txt
	@echo "Makefile: Running Safety"
	safety check --policy-file $(safety_install_policy_file) -r minimum-constraints-install.txt --full-report || test '$(RUN_TYPE)' == 'normal' || exit 1
	safety check --policy-file $(safety_develop_policy_file) -r minimum-constraints-develop.txt --full-report || test '$(RUN_TYPE)' == 'normal' || test '$(RUN_TYPE)' == 'scheduled' || exit 1
	@echo "Makefile: Done running Safety"

.PHONY: check_reqs_prepare
check_reqs_prepare: Makefile
	@echo "Makefile: Preparing check for missing and extra install dependencies of this package"
	pip freeze | cut -d '=' -f 1 | grep -v '@' | tr '-' '.' | tr '_' '.' >tmp_initial-packages.txt

.PHONY: check_reqs_install
check_reqs_install: Makefile $(done_dir)/install_$(pymn)_$(PACKAGE_LEVEL).done minimum-constraints-install.txt
	@echo "Makefile: Checking missing and extra install dependencies of this package"
# Create empty tmp_initial-packages.txt for local runs that missed running check_reqs_prepare
	touch tmp_initial-packages.txt
	pip freeze | cut -d '=' -f 1 | grep -v '@' | tr '-' '.' | tr '_' '.' | grep -v -F -f tmp_initial-packages.txt | xargs -I {} sh -c 'if ! grep -iE ^{}== minimum-constraints-install.txt >/dev/null; then sh -c "pip freeze | grep -iE ^{}=="; fi' >tmp_missing-reqs.txt
	if [ -s tmp_missing-reqs.txt ]; then echo 'Error: Missing packages in minimum-constraints-install.txt compared to what is installed:'; cat tmp_missing-reqs.txt; exit 1; fi
	rm -f tmp_missing-reqs.txt
	for pkg in $$(grep -E '^[a-z_0-9A-Z\-\.]+==' minimum-constraints-install.txt | cut -d '=' -f 1 | sort | uniq); do if ! pip show $$pkg >/dev/null 2>&1; then echo $$pkg; fi; done >extra_reqs_install_$(PLATFORM)_$(pymn)_$(PACKAGE_LEVEL).txt
	if [ -s extra_reqs_install_$(PLATFORM)_$(pymn)_$(PACKAGE_LEVEL).txt ]; then echo 'Warning: Extra packages in minimum-constraints-install.txt compared to what is installed:'; cat extra_reqs_install_$(PLATFORM)_$(pymn)_$(PACKAGE_LEVEL).txt; fi
	@echo "Makefile: Done checking missing and extra install dependencies of this package"
	@echo "Makefile: $@ done."

.PHONY: check_reqs
check_reqs: Makefile $(done_dir)/develop_$(pymn)_$(PACKAGE_LEVEL).done minimum-constraints-install.txt minimum-constraints-develop.txt requirements.txt
	@echo "Makefile: Checking missing and extra dependencies of this package"
ifeq ($(PLATFORM),Windows_native)
# Reason for skipping on Windows is https://github.com/r1chardj0n3s/pip-check-reqs/issues/67
	@echo "Makefile: Warning: Skipping the use of pip-missing-reqs on native Windows" >&2
else
	pip-missing-reqs $(package_name) --ignore-module $(package_name) --requirements-file=requirements.txt
	pip-missing-reqs $(package_name) --ignore-module $(package_name) --requirements-file=minimum-constraints-install.txt
endif
	cat minimum-constraints-develop.txt minimum-constraints-install.txt >tmp_minimum-constraints.txt
# Create empty tmp_initial-packages.txt for local runs that missed running check_reqs_prepare
	touch tmp_initial-packages.txt
	pip freeze | cut -d '=' -f 1 | grep -v '@' | tr '-' '.' | tr '_' '.' | grep -v -F -f tmp_initial-packages.txt | xargs -I {} sh -c 'if ! grep -iE ^{}== tmp_minimum-constraints.txt >/dev/null; then sh -c "pip freeze | grep -iE ^{}=="; fi' >tmp_missing-reqs.txt
	if [ -s tmp_missing-reqs.txt ]; then echo 'Error: Missing packages in minimum-constraints files compared to what is installed:'; cat tmp_missing-reqs.txt; exit 1; fi
	rm -f tmp_missing-reqs.txt tmp_initial-packages.txt
	for pkg in $$(grep -E '^[a-z_0-9A-Z\-\.]+==' tmp_minimum-constraints.txt | cut -d '=' -f 1 | sort | uniq); do if ! pip show $$pkg >/dev/null 2>&1; then echo $$pkg; fi; done >extra_reqs_all_$(PLATFORM)_$(pymn)_$(PACKAGE_LEVEL).txt
	if [ -s extra_reqs_all_$(PLATFORM)_$(pymn)_$(PACKAGE_LEVEL).txt ]; then echo 'Warning: Extra packages in minimum-constraints files compared to what is installed:'; cat extra_reqs_all_$(PLATFORM)_$(pymn)_$(PACKAGE_LEVEL).txt; fi
	rm -f tmp_minimum-constraints.txt
	@echo "Makefile: Done checking missing dependencies of this package"
	@echo "Makefile: $@ done."

.PHONY: test
test: $(test_unit_py_files)
	@echo "Makefile: Running unit tests on local package"
	py.test --color=yes $(pytest_cov_opts) $(pytest_warning_opts) $(pytest_opts) $(test_unit_dir) -s
	@echo "Makefile: Done running unit tests"

.PHONY: testdict
testdict: $(test_unit_py_files)
	@echo "Makefile: Running unit tests against standard dict"
	TEST_DICT=1 py.test --color=yes $(pytest_warning_opts) $(pytest_opts) $(test_unit_dir) -s
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
