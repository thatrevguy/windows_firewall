#Applies rules in hiera under specified key name.
class windows_firewall::rule(
  $rule_key = 'windows_networks',
) {
    $defaults = {
        'protocol' => 6,
        'direction' => 1,
        'interface_types' => 'all',
        'enabled' => true,
        'profiles' => 2147483647,
        'edge_traversal' => false,
        'action' => 1,
        'edge_traversal_options' => 0,
    }
    create_resources(firewall_rule, hiera_hash($rule_key), $defaults)
}