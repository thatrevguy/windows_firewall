#Returns key value pair of all enabled firewall rule properties in json string. Auditing will need to develop a process on how to interpret data. Will be stored in PuppetDB.
$Rules = $WindowsFirewall.Rules | where {$_.Direction -eq 1 -and $_.Enabled -eq 'True'} | Select-Object Name,LocalPorts,RemoteAddresses,Action | ConvertTo-Json -Compress
Write-Host "windows_firewall_rule_report=$Rules"