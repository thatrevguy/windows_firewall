class windows_firewall (
    $profile_state = 'on',
    $in_policy = 'BlockInbound',
    $out_policy = 'AllowOutbound',
){
    case $::operatingsystemversion {
        /(Windows Server 2008|Windows Server 2012)/: {
            class { 'windows_firewall::profile':
                profile_state => $profile_state,
            }->
            class { 'windows_firewall::policy':
                in_policy => $in_policy,
                out_policy => $out_policy,
            }->
            class { 'windows_firewall::baseline_rules': }

            $firewall_name = 'MpsSvc'
            service { 'windows_firewall':
                ensure => 'running',
                name => $firewall_name,
                enable => true,
            }
        }
        default: {
            notify {"${::operatingsystemversion} not supported": }
        }
    }
}