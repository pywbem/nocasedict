# Makefile for Fedora packaging
#
# This Makefile can be used before the package has a Fedora packaging repo.
#
# Preconditions:
# - Be on Fedora when running make with this Makefile
# - Have a userid on FAS (https://admin.fedoraproject.org/), e.g. "johndoe"
# - Have a ~/.fedora.upn file on your local Fedora system with your FAS userid:
#   echo "johndoe" >~/.fedora.upn
# - Have a ~/.config/copr file on your local Fedora system with the config for
#   your userid on FAS as obtained from https://copr.fedorainfracloud.org/api/


# No built-in rules needed:
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

os_id := $(shell source /etc/os-release && echo $$ID)

# Fedora version to build against
fedora_release := f34
fedora_release_file := fc34

pypi_name := $(shell cd ../.. && ./setup.py --name)
pypi_version := $(shell cd ../.. && ./setup.py --version)

package_name := python-$(pypi_name)
package_version := $(pypi_version)
package_release := $(shell grep 'Release:' *.spec | cut -d ':' -f 2 | tr -d ' ' | cut -d '%' -f 1)

pypi_file := $(pypi_name)-$(pypi_version).tar.gz
spec_file := $(package_name).spec
srpm_file := $(package_name)-$(package_version)-$(package_release).$(fedora_release_file).src.rpm
rpm_file := $(package_name)-$(package_version)-$(package_release).$(fedora_release_file).rpm

.PHONY: help
help:
	@echo "Makefile for Fedora packaging of $(package_name) $(package_version)-$(package_release)"
	@echo ""
	@echo "Valid make targets:"
	@echo "develop     - Install any preconditions"
	@echo "srpm        - Build the SRPM file for the package"
	@echo "build       - Build the RPM file for the package locally"
	@echo "build_copr  - Build the RPM file for the package on COPR"
	@echo "build_koji  - Build the RPM file for the package on Koji"
	@echo "all         - All of the above"
	@echo "clobber     - Remove any build artefacts"

.PHONY: all
all: develop srpm build build_koji build_copr

.PHONY: _check_fedora
_check_fedora:
ifneq ($(os_id),fedora)
	$(error OS must be fedora but is: $(os_id))
endif

.PHONY: clobber
clobber:
	rm *.done
	rm *.tar.gz *.src.rpm
	@echo "Makefile: Target $@ done."

.PHONY: develop
develop: _check_fedora develop.done
	@echo "Makefile: Target $@ done."

.PHONY: srpm
srpm: _check_fedora $(srpm_file)
	@echo "Makefile: Target $@ done."

.PHONY: build
build: _check_fedora build.done
	@echo "Makefile: Target $@ done."

.PHONY: _check_fedora build_koji
build_koji: build_koji.done
	@echo "Makefile: Target $@ done."

.PHONY: _check_fedora build_copr
build_copr: build_copr.done
	@echo "Makefile: Target $@ done."


kinit.done:
	@echo "When asked, enter the password for your FAS userid"
	kinit $(shell cat ~/.fedora.upn)@FEDORAPROJECT.ORG
	echo "done" >$@

develop.done:
	sudo -H dnf install -y rpm-build fedora-packager copr-cli python3-devel python3-setuptools
	# For testing:
	sudo -H dnf install -y python3-pytest python3-virtualenv python3-packaging python3-pluggy python3-six python3-pathlib2
	echo "done" >$@

$(pypi_file): $(spec_file)
	spectool -g $(spec_file)
	touch $(pypi_file)

$(srpm_file): Makefile $(pypi_file) $(spec_file)
	fedpkg --release $(fedora_release) srpm

#$(rpm_file): Makefile $(srpm_file) $(spec_file)
#	# This would be the command in a Fedora packaging repo clone:
#	fedpkg --release $(fedora_release) mockbuild --mock-config fedora-rawhide-x86_64 -N

build.done: $(srpm_file) $(spec_file)
	cp $(pypi_file) ~/rpmbuild/SOURCES
	rpmbuild -bb $(spec_file)
	echo "done" >$@

build_koji.done: Makefile kinit.done $(srpm_file)
	# This would be the command in a Fedora packaging repo clone:
	# fedpkg --release $(fedora_release) scratch-build --srpm --fail-fast
	koji build --scratch $(fedora_release) $(srpm_file)
	echo "done" >$@

build_copr.done: $(srpm_file)
	copr-cli build $(package_name) $(srpm_file)
	echo "done" >$@
