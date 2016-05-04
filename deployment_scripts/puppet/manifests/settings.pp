notice('MODULAR: detach-haproxy/settings.pp')

sysctl::value{'net.ipv4.ip_forward': value=>'1'}
