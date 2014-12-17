#Encapsulates policy and rule classes.
#Can disable postrun_facts and control_rules. 
#"rule_key" value used to identify key name that stores firewall rules in Hiera.
class windows_firewall (
    $profile_state = 'on',
    $in_policy = 'BlockInbound',
    $out_policy = 'AllowOutbound',
    $control_rules = false,
    $rule_key = 'windows_networks',
    $postrun_facts = false,
){
    case $::operatingsystemversion {
        /(Windows Server 2008|Windows Server 2012)/: {
            $firewall_name = 'MpsSvc'

            service { 'windows_firewall':
                ensure => 'running',
                name   => $firewall_name,
                enable => true,
            }->
            class { 'windows_firewall::profile':
                profile_state => $profile_state,
            }->
            class { 'windows_firewall::policy':
                in_policy  => $in_policy,
                out_policy => $out_policy,
            }->
            file { "${::puppet_vardir}/files":
                ensure => directory,
            }->
            file { "${::puppet_vardir}/files/windows_firewall_cmdlt.ps1":
                ensure             => present,
                source_permissions => ignore,
                source             => 'puppet:///modules/windows_firewall/windows_firewall_cmdlt.ps1',
            }->
            firewall_rule { 'rules':
                apply => 'false',
                rule_hash => hiera_hash($rule_key),
            }->
            class { 'windows_firewall::rule_controller':
                enabled  => $control_rules,
                rule_key => $rule_key,
            }~>
            class { 'windows_firewall::postrun_facts':
                enabled => $postrun_facts,
            }
        }
        default: {
            notify {"${::operatingsystemversion} not supported": }
        }
    }
}