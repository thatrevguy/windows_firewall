#Applies preferred policy to all profiles.
class windows_firewall::policy(
  $in_policy = 'AllowInbound',
  $out_policy = 'AllowOutbound',
) {
    validate_re($in_policy,['^(AllowInbound|BlockInbound)$'])
    validate_re($out_policy,['^(AllowOutbound|BlockOutbound)$'])

    $netsh = "C:\\Windows\\System32\\netsh.exe"
    $firewall_policy = "${in_policy},${out_policy}"
    $arguments = 'advfirewall set allprofiles firewallpolicy'
    $command = "${netsh} ${arguments} ${firewall_policy}"

    if($::in_policy_fact != $in_policy) or ($::out_policy_fact != $out_policy){
        exec { "Setting default policy to ${in_policy},${out_policy}":
            command  => $command,
            provider => windows,
        }
    }
}