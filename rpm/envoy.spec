Summary: Envoy proxy binary for CentOS 6
Name: envoy
Version: %{_version}
Release: %{_build}
License: Apache License 2.0
BuildRoot: %{_tmppath}/%{name}-buildroot

%description
Envoy proxy is a L3/4/7 proxy that supports H2, routing, rate limiting, tracing and metrics.

%pre
# Create the user account for the service if it doesn't exist
/usr/bin/getent group "envoy" >/dev/null || /usr/sbin/groupadd "envoy" || :
/usr/bin/getent passwd "envoy" >/dev/null || /usr/sbin/useradd -g "envoy" -s /sbin/nologin -M "envoy" 2> /dev/null || :
mkdir -p /var/log/envoy
chown envoy:envoy /var/log/envoy
mkdir -p /etc/rtr/envoy
chown envoy:envoy /etc/rtr/envoy

%post
/sbin/chkconfig --add envoy

%files
%attr(555,root,root) /usr/bin/envoy
%config(noreplace) %attr(755,root,root) /etc/init.d/envoy

%preun
service stop envoy
/sbin/chkconfig --list envoy && /sbin/chkconfig --del envoy

%postun
