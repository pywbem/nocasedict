%global srcname nocasedict

Name:           python-%{srcname}
Version:        1.0.2
Release:        1%{?dist}
Summary:        A case-insensitive ordered dictionary for Python

License:        LGPLv2+
URL:            https://github.com/pywbem/nocasedict
Source0:        %{pypi_source}
BuildArch:      noarch

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

%package -n python%{python3_pkgversion}-%{srcname}
Summary:        %{summary}
Requires:       python%{python3_pkgversion}-six
BuildRequires:  python%{python3_pkgversion}-devel
BuildRequires:  python%{python3_pkgversion}-setuptools
# Test deps
BuildRequires:  python%{python3_pkgversion}-pytest

%description -n python%{python3_pkgversion}-%{srcname} %{_description}

%prep
%autosetup -n %{srcname}-%{version}

%build
%py3_build

%install
%py3_install

%check
%{python3} setup.py test

%files -n python%{python3_pkgversion}-%{srcname}
%license LICENSE
%doc README.md
%{python3_sitelib}/%{srcname}*.egg-info/
%{python3_sitelib}/%{srcname}/

%changelog
* Sat Jul 17 2021 Andreas Maier <andreas.r.maier@gmx.de> 1.0.2-1
- Bumped version to 1.0.2
- Removed duplicate BuildRequires statements
- Changed Python package references to use python3_pkgversion

* Tue Sep 22 2020 Andreas Maier <andreas.r.maier@gmx.de> 1.0.0-1
- Initial packaging
