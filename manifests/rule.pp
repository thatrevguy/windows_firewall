define windows_firewall::rule(
    $ensure = 'present',
    $advanced = 'no',
    $attr_name = '',
) {

    validate_re($ensure,['^(present|absent)$'])
    validate_re($advanced,['^(yes|no)$'])

    exec { 'test':
        command => template('windows_firewall/check_rule_exist.ps1'),
        provider => powershell,
    }
}