notice('MODULAR: detach-haproxy/openstack-haproxy-mysqld-status.pp')

$mysql_hash               = hiera_hash('mysql', {})
$use_mysql                = pick($mysql_hash['enabled'], true)
$custom_mysql_setup_class = hiera('custom_mysql_setup_class', 'galera')
$external_lb              = hiera('external_lb', false)

# only do this if mysql is enabled and we are using one of the galera/percona classes
if !$external_lb and $use_mysql and ($custom_mysql_setup_class in ['galera', 'percona', 'percona_packages']) {
  $database_address_map = get_node_to_ipaddr_map_by_network_role(hiera_hash('database_nodes'), 'mgmt/database')
  $server_names         = hiera_array('mysqld_names', keys($database_address_map))
  $ipaddresses          = hiera_array('mysqld_ipaddresses', values($database_address_map))
  $public_virtual_ip    = hiera('public_vip')
  $internal_virtual_ip  = hiera('management_vip')

  Openstack::Ha::Haproxy_service {
    internal_virtual_ip => $internal_virtual_ip,
    ipaddresses         => $ipaddresses,
    public_virtual_ip   => $public_virtual_ip,
    server_names        => $server_names,
  }

  openstack::ha::haproxy_service { 'mysqld-status':
    order                  => '115',
    public                 => true,
    listen_port            => 49000,
    balancermember_port    => 49000,
    define_backups         => false,
    haproxy_config_options => {
      'option'       => ['httpchk', 'httplog','httpclose'],
      'http-request' => 'set-header X-Forwarded-Proto https if { ssl_fc }',
    },
    balancermember_options => 'check port 49000 inter 20s fastinter 2s downinter 2s rise 3 fall 3',
  }
}
