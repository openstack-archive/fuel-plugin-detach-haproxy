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
")
}

