class windows_firewall::rule_controller (
    $enabled = false,
	$rule_key,
){
    if $enabled == true {
	    $rules = hiera_hash($rule_key)
        exec { 'apply_rules':
            command => template('windows_firewall/apply_rules.ps1'),
            unless => template('windows_firewall/validate_rules.ps1'),
            provider => powershell,						
        }
    }
}