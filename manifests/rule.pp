define windows_firewall::rule(
    $ensure = 'present',
    $display_name = $title,
    $description = '',
    $application_name = '',
    $service_name = '',
    $protocol = 'TCP',
    $local_ports = '',
    $remote_ports = '',
    $local_addresses = '',
    $remote_addresses = '',
    $icmp_types_and_codes = '',
    $direction = 'In',
    $interfaces = '',
    $interface_types = 'All',
    $enabled = 'True',
    $grouping = '',
    $profiles = 'Domain,Private,Public',
    $edge_traversal = 'False',
    $action = 'Allow',
    $edge_traversal_options = 'Block',
) {

    validate_re($ensure,['^(present|absent)$'])
    validate_re($display_name,['^.*$'])
    validate_re($protocol,['^(ICMPv4|IGMP|TCP|UDP|IPv6|IPv6Route|IPv6Frag|GRE|ICMPv6|IPv6NoNxt|IPv6Opts|VRRP|PGM|L2TP)$'])
    validate_re($direction,['^(In|Out)$'])
    validate_re($interface_types,['^(((Wireless|Lan|RemoteAccess)(,(?!$))?(?!\3)){1,2}|All)$'])
    validate_re($enabled,['^(True|False)$'])
    validate_re($profiles,['^((Domain|Private|Public)(,(?!$))?(?!.*\2)){1,3}$'])
    validate_re($edge_traversal,['^(True|False)$'])
    validate_re($action,['^(Allow|Block)$'])
    validate_re($edge_traversal_options,['^(Block|Allow|Defer to App|Defer to User)$'])

    if $ensure == 'present' {
        $command = 'windows_firewall/add_rule.ps1'
        $unless = template('windows_firewall/get_rule.ps1')
        $onlyif = undef
    }
    else {
        $command = 'windows_firewall/remove_rule.ps1'
        $unless = undef
        $onlyif = template('windows_firewall/get_rule.ps1')
    }

    exec { "Rule not ${ensure}":
        command => template("${command}"),
        unless => $unless,
        onlyif => $onlyif,
        provider => powershell,
    }

    if $ensure == 'present' {

        exec { "Rule property value mismatch found":
            command => template('windows_firewall/set_rule.ps1'),
            unless => template('windows_firewall/validate_rule.ps1'),
            provider => powershell,
        }

        exec { "Rule duplicate found":
            command => template('windows_firewall/prune_rule.ps1'),
            unless => template('windows_firewall/duplicate_check.ps1'),
            provider => powershell,
        }
    }
}