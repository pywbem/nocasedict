%global srcname nocasedict

Name:           python-%{srcname}
Version:        1.0.0
Release:        1%{?dist}
Summary:        A case-insensitive ordered dictionary for Python

License:        LGPLv2+
URL:            https://github.com/pywbem/nocasedict
Source:         %{pypi_source}

BuildArch:      noarch

Requires:       python3dist(six)

BuildRequires:  python3-devel
BuildRequires:  python3dist(setuptools)

# Test deps
BuildRequires:  python3dist(pytest)

%global _description %{expand:
Python class 'NocaseDict' is a case-insensitive ordered dictionary that
preserves the original lexical case of its keys.

It supports the functionality of the built-in 'dict' class of Python 3.8 on all
Python versions it supports with the following exceptions (and the
case-insensitivity of course):

* The 'iter..()', 'view..()' and 'has_key()' methods are only present
  on Python 2, consistent with the built-in 'dict' class.

* The 'keys()', 'values()' and 'items()' methods return a list on Python 2
  and a dictionary view on Python 3, consistent with the built-in 'dict'
  class.}

%description %{_description}

%package -n python3-%{srcname}
Summary:        %{summary}
Requires:       python3dist(six)
BuildRequires:  python3-devel
BuildRequires:  python3dist(setuptools)
# Test deps
BuildRequires:  python3dist(pytest)

%description -n python3-%{srcname} %_description

%prep
%autosetup -n %{srcname}-%{version}

%build
%py3_build

%install
%py3_install

%check
%{python3} setup.py test

%files -n python3-%{srcname}
%license LICENSE
%doc README.rst
%{python3_sitelib}/%{srcname}*.egg-info/
%{python3_sitelib}/%{srcname}/

%changelog
* Tue Sep 22 2020 Andreas Maier <andreas.r.maier@gmx.de> 1.0.0-1
- Initial packaging
