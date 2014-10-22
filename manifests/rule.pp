define windows_firewall::rule(
    $ensure = 'present',
    $attr_name = '',
    $attr_value = '',
) {

    validate_re($ensure,['^(present|absent)$'])

    if $ensure == 'present' {
        $command = 'windows_firewall/add_rule.ps1'
        $unless = template('windows_firewall/check_rule_exist.ps1')
        $onlyif = undef
    }
    else {
        $command = 'windows_firewall/remove_rule.ps1'
        $unless = undef
        $onlyif = template('windows_firewall/check_rule_exist.ps1')
    }

    exec { "Rule not ${ensure}":
        command => template("${command}"),
        unless => $unless,
        onlyif => $onlyif,
        provider => powershell,
    }

    if $ensure == 'present' {
        exec { "Rule attribute value mismatch":
            command => template('windows_firewall/set_rule_value.ps1'),
            unless => template('windows_firewall/check_rule_value.ps1'),
            provider => powershell,
        }
    }
}