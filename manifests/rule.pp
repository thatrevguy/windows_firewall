#Applies rules in hiera under specified key name.
define windows_firewall::rule(
) {
    $defaults = {
        protocol               => 6,
        description            => '',
        application_name       => '',
        service_name           => '',
        local_ports            => '',
        remote_ports           => '',
        local_addresses        => '',
        remote_addresses       => '',
        icmp_types_and_codes   => '',
        direction              => 1,
        interfaces             => '',
        interface_types        => 'All',
        enabled                => true,
        grouping               => '',
        profiles               => 2147483647,
        edge_traversal         => false,
        action                 => 1,
        edge_traversal_options => 0,
    }
    create_resources(firewall_rule, hiera_hash($title), $defaults)
}
