class windows_firewall (
    $profile_state = 'on',
    $in_policy = 'BlockInbound',
    $out_policy = 'AllowOutbound',
){
    case $::operatingsystemversion {
        /(Windows Server 2008|Windows Server 2012)/: {
            class { 'windows_firewall::profile':
                profile_state => $profile_state,
            }
            class { 'windows_firewall::policy':
                in_policy => $in_policy,
                out_policy => $out_policy,
            }

            windows_firewall::rule { 'Test Rule':
                ensure => 'present',
                attr_name => 'testrule',
                attr_value => 'v2.22|Action=Allow|Active=TRUE|Dir=In|Protocol=1|Name=test rule|Desc=test rule|',
            }

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