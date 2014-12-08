#Defines state of all profiles.
class windows_firewall::profile(
  $profile_state = 'off',
) {
    validate_re($profile_state,['^(on|off)$'])

    if $::profile_state_fact != $profile_state {
        $command = "c:\\Windows\\System32\\netsh.exe advfirewall set allprofiles state ${profile_state}"
        exec { "Turn profiles ${profile_state}":
            command  => $command,
            provider => windows,
        }
    }
}