notice('MODULAR: detach-haproxy/add_to_hiera.pp')

$plugin_name      = 'detach_haproxy'
$network_metadata = hiera_hash('network_metadata', {})
$haproxy_roles    = ['primary-standalone-haproxy', 'standalone-haproxy']
$haproxy_nodes    = get_nodes_hash_by_roles($network_metadata, $haproxy_roles)

$mgmt_ip   = $network_metadata['vips']['haproxy']['ipaddr']
$public_ip = $network_metadata['vips']['haproxy_public']['ipaddr']

if roles_include($haproxy_roles){
  $haproxy = true
} else {
  $haproxy = false
}

# Since fuel-library saves database_vip in globals.yaml we need to calulate
# this VIP value here in order to not conflict with detach-database plugin.
$detach_database_plugin = hiera('detach-database', {})
$detach_database_yaml = pick($detach_database_plugin['yaml_additional_config'], "{}")
$detach_database_settings_hash = parseyaml($detach_database_yaml)
$database_vip = pick($detach_database_settings_hash['remote_database'],
                  try_get_value($vips, 'database/ipaddr', $mgmt_ip))

file {"/etc/hiera/plugins/${plugin_name}.yaml":
  ensure  => file,
    content => inline_template("# Created by puppet, please do not edit manually
network_metadata:
  vips:
<% unless @haproxy -%>
    haproxy:
      namespace: false
    haproxy_public:
      namespace: false
<% end -%>
    management:
      ipaddr: <%= @mgmt_ip %>
<% if @haproxy -%>
      namespace: haproxy
<% else -%>
      namespace: false
<% end -%>
    public:
      ipaddr: <%= @public_ip %>
<% if @haproxy -%>
      namespace: haproxy
<% else -%>
      namespace: false
<% end -%>
<% if @haproxy -%>
corosync_roles: <%= @haproxy_roles %>
colocate_haproxy: false
<% end -%>
run_ping_checker: false
colocate_haproxy: false
service_endpoint: <%= @mgmt_ip %>
management_vip: <%= @mgmt_ip %>
public_vip: <%= @public_ip %>
database_vip: <%= @database_vip %>
")
}
