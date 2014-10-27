#Generate rule types from pre-existing system rules that are enabled and inbound
$Path = 'C:\baseline_rules.pp'
New-Item -Path $Path -Type File -Force
"class windows_firewall::baseline_rules {`r" | Out-File -FilePath $Path -Append

$Firewall = New-Object -ComObject HNetCfg.FWPolicy2

foreach($Rule in ($Firewall.Rules | where {$_.Direction -eq 1 -and $_.enabled -eq "True"}))
{
	"    windows_firewall::rule { `'" + $Rule.Name + "`':`r" | Out-File -FilePath $Path -Append
	"        description => `'" + $Rule.Description + "`',`r" | Out-File -FilePath $Path -Append
	"        application_name => `'" + ($Rule.ApplicationName -replace "\\", "\\") + "`',`r" | Out-File -FilePath $Path -Append
	"        service_name => `'" + $Rule.ServiceName + "`',`r" | Out-File -FilePath $Path -Append
	"        protocol => `'" + $Rule.Protocol + "`',`r" | Out-File -FilePath $Path -Append
	"        local_ports => `'" + $Rule.LocalPorts + "`',`r" | Out-File -FilePath $Path -Append
	"        remote_ports => `'" + $Rule.RemotePorts + "`',`r" | Out-File -FilePath $Path -Append
	"        local_addresses => `'" + $Rule.LocalAddresses + "`',`r" | Out-File -FilePath $Path -Append
	"        remote_addresses => `'" + $Rule.RemoteAddresses + "`',`r" | Out-File -FilePath $Path -Append
	"        icmp_types_and_codes => `'" + $Rule.IcmpTypesAndCodes + "`',`r" | Out-File -FilePath $Path -Append
	"        direction => `'" + $Rule.Direction + "`',`r" | Out-File -FilePath $Path -Append
	"        interfaces => `'" + $Rule.Interfaces + "`',`r" | Out-File -FilePath $Path -Append
	"        interface_types => `'" + $Rule.InterfaceTypes + "`',`r" | Out-File -FilePath $Path -Append
	"        enabled => `'" + $Rule.Enabled + "`',`r" | Out-File -FilePath $Path -Append
	"        grouping => `'" + $Rule.Grouping + "`',`r" | Out-File -FilePath $Path -Append
	"        profiles => `'" + $Rule.Profiles + "`',`r" | Out-File -FilePath $Path -Append
	"        edge_traversal => `'" + $Rule.EdgeTraversal + "`',`r" | Out-File -FilePath $Path -Append
	"        action => `'" + $Rule.Action + "`',`r" | Out-File -FilePath $Path -Append
	"        edge_traversal_options => `'" + $Rule.EdgeTraversalOptions + "`',`r" | Out-File -FilePath $Path -Append
	"    }`n" | Out-File -FilePath $Path -Append
}

"}" | Out-File -FilePath $Path -Append