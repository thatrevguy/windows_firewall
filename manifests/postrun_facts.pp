class windows_firewall::postrun_facts (
){
    if $::postrun_facts == true {
        exec { 'update_facts':
            command => "\"${::env_windows_installdir}\\bin\\puppet.bat\" facts upload",
            provider => windows,
            refreshonly => true,
        }
    }
}