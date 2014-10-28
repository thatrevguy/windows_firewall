class windows_firewall (
    $profile_state = 'on',
    $in_policy = 'BlockInbound',
    $out_policy = 'AllowOutbound',
){
    case $::operatingsystemversion {
        /(Windows Server 2008|Windows Server 2012)/: {
            $firewall_name = 'MpsSvc'

            service { 'windows_firewall':
                ensure => 'running',
                name => $firewall_name,
                enable => true,
            }->
            class { 'windows_firewall::profile':
                profile_state => $profile_state,
            }->
            class { 'windows_firewall::policy':
                in_policy => $in_policy,
                out_policy => $out_policy,
            }->
            class { 'windows_firewall::baseline_rules':
            }->
            exec { 'Disable all undefined rules':
                command => template('windows_firewall/disable_rule.ps1'),
                provider => powershell,
            }
        }
        default: {
            notify {"${::operatingsystemversion} not supported": }
        }
    }
}