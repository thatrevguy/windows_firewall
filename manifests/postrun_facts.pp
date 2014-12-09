#Encapsulates update_facts so it may be disabled. 
#If enabled "puppet facts upload" is run post configuration.
class windows_firewall::postrun_facts (
    $enabled = false,
){
    if $enabled == true {
        $puppet_bat = "\"${::env_windows_installdir}\\bin\\puppet.bat\""
        $arguments = 'facts upload'
        $command = "${puppet_bat} ${arguments}"
        exec { 'update_facts':
            command     => $command,
            provider    => windows,
            refreshonly => true,
        }
    }
}