# Packaging for Fedora distribution

## General information

* [Fedora: Join the package collection maintainers](https://fedoraproject.org/wiki/Join_the_package_collection_maintainers)
* [Fedora Packaging Guidelines](https://docs.fedoraproject.org/en-US/packaging-guidelines/)
* [Fedora Python Packaging Guidelines](https://docs.fedoraproject.org/en-US/packaging-guidelines/Python/)
* [RPM Packaging Guide](https://rpm-packaging-guide.github.io/)

## Other Python Fedora packages

Here are some other packages for info:

* https://src.fedoraproject.org/rpms/python-tabulate/blob/master/f/python-tabulate.spec
* https://src.fedoraproject.org/rpms/python-six/blob/master/f/python-six.spec
* https://src.fedoraproject.org/rpms/python-werkzeug/blob/master/f/python-werkzeug.spec
* https://src.fedoraproject.org/rpms/poetry/blob/master/f/poetry.spec

## Environment setup

1. You need to have a Fedora system and do all this on that system.

2. Setup for Makefile:

   The Makefile can be used before the package has a Fedora packaging repo.

   - Have a userid on FAS (https://admin.fedoraproject.org/)
     e.g. "johndoe"

   - Have a ~/.fedora.upn file on your local Fedora system with your FAS userid:
     echo "johndoe" >~/.fedora.upn

   - Have a ~/.config/copr file on your local Fedora system with the config for
     your userid on FAS as obtained from https://copr.fedorainfracloud.org/api/

3. Setup for working in Fedora package repo clone:

   - Your userid on the local Fedora system must be in the mock group.
     See https://github.com/rpm-software-management/mock/wiki#setup

   - Your user info to be used by git for the package repo on src.fedoraproject.com:
     git config --global user.name "John Doe"
     git config --global user.email "john.doe@web.de"

## Test-building the Fedora package

* Build using the Makefile:

  make all

## Some more info

* Koji build targets can be listed with:

  koji list-targets

* Listing a Koji build:

  https://koji.fedoraproject.org/koji/taskinfo?taskID=TASKID

## Local .spec file

The local python-nocasedict.spec file is the initial .spec file for general
information. It is not kept up to date. The authoritative version of the
.spec file is on https://src.fedoraproject.org/rpms/python-nocasedict.
