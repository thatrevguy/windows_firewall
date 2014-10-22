define windows_firewall::rule(
    $ensure = 'present',
    $advanced = 'no',
    $attr_name = '',
) {

    validate_re($ensure,['^(present|absent)$'])
	validate_re($advanced,['^(yes|no)$'])

    $attr_value = "C:\\Windows\\System32\\netsh.exe advfirewall firewall show rule name=\"${attr_name}\""
    notify { "${attr_value}": }
}
CoreNet-ICMP6-DU-In