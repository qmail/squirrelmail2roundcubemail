#
# spec file for package squirrelmail2roundcubemail
#
# Copyright (C) 2013 Johannes Weberhofer - http://www.weberhofer.at/
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.


Name:           squirrelmail2roundcubemail
Version:        1.0
Release:        0
Summary:        Migrate Squirrelmail address books to Roundcubemail MySQL accounts
License:        GPL-2.0
Url:            https://github.com/weberhofer/squirrelmail2roundcubemail
Group:          Productivity/Networking/Email/Servers
Source0:        squirrelmail2roundcubemail-%{version}.tar.bz2

Requires:       perl(DBD::mysql::db)
Requires:       perl(Text::CSV_XS)
Requires:       perl(Text::CSV)

BuildArch:      noarch

BuildRoot:      %{_tmppath}/%{name}-%{version}-buildroot


%description
Scripts to migrate address books from squirrelmail acounts to
MySQL stored Roundcubemail accounts

%prep
%setup -n src

%build

%install
%{__mkdir_p} %{buildroot}%{_datadir}/%{name}
%{__mkdir_p} %{buildroot}/%{_sysconfdir}
%{__mkdir_p} %{buildroot}/%{_sbindir}
%{__cp} * %{buildroot}%{_datadir}/%{name}/
%{__mv} %{buildroot}%{_datadir}/%{name}/dbconfig.pl %{buildroot}%{_sysconfdir}/%{name}-db.conf
%{__ln_s} %{_sysconfdir}/%{name}-db.conf %{buildroot}%{_datadir}/%{name}/dbconfig.pl
%{__ln_s} %{_datadir}/%{name}/%{name}.sh %{buildroot}/%{_sbindir}/%{name}

%files
%defattr(-,root,root,0755)
%{_datadir}/%{name}
%{_sbindir}/%{name}
%attr(0660, root, root) %config(noreplace) %{_sysconfdir}/%{name}-db.conf

%changelog
