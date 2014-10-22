class windows_firewall::policy(
  $in_policy = 'AllowInbound',
  $out_policy = 'AllowOutbound',
) {
    validate_re($in_policy,['^(AllowInbound|BlockInbound)$'])
    validate_re($out_policy,['^(AllowOutbound|BlockOutbound)$'])

    $command = "c:\\Windows\\System32\\netsh.exe advfirewall set allprofiles firewallpolicy ${in_policy},${out_policy}"

    if ($::in_policy_fact != $in_policy) or ($::out_policy_fact != $out_policy) {
        exec { "Setting default policy to ${in_policy},${out_policy}":
            command => $command,
            provider => windows,
        }
    }
}