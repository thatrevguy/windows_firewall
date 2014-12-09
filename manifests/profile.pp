#Defines state of all profiles.
class windows_firewall::profile(
  $profile_state = 'off',
) {
    validate_re($profile_state,['^(on|off)$'])

    if $::profile_state_fact != $profile_state {
        $netsh = "C:\\Windows\\System32\\netsh.exe"
        $arguments = 'advfirewall set allprofiles state'
        $command = "${netsh} ${arguments} ${profile_state}"
        exec { "Turn profiles ${profile_state}":
            command  => $command,
            provider => windows,
        }
    }
}