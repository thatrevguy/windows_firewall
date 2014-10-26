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
            unless => template('windows_firewall/get_rule.ps1'),
            provider => powershell,
        }
    }
}