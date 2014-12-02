$Path = 'C:\base_windows_rules.json'
$RuleHash = @{}
foreach($Rule in ($Firewall.Rules | where {$_.Direction -eq 1 -and $_.enabled -eq "True"}))
{
    $Properties = $Rule | Select-Object `
        @{Name='description';E={$_.Description}}, `
        @{Name='application_name';E={$_.ApplicationName}}, `
        @{Name='service_name';E={$_.serviceName}}, `
        @{Name='protocol';E={$_.Protocol}}, `
        @{Name='local_ports';E={$_.LocalPorts}}, `
        @{Name='remote_ports';E={$_.RemotePorts}}, `
        @{Name='local_addresses';E={$_.LocalAddresses}}, `
        @{Name='remote_addresses';E={$_.RemoteAddresses}}, `
        @{Name='icmp_types_and_codes';E={$_.IcmpTypesAndCodes}}, `
        @{Name='direction';E={$_.Direction}}, `
        @{Name='interfaces';E={$_.Interfaces}}, `
        @{Name='interface_types';E={$_.InterfaceTypes}}, `
        @{Name='enabled';E={$_.Enabled}}, `
        @{Name='grouping';E={$_.Grouping}}, `
        @{Name='profiles';E={$_.Profiles}}, `
        @{Name='edge_traversal';E={$_.EdgeTraversal}}, `
        @{Name='action';E={$_.Action}}, `
        @{Name='edge_traversal_options';E={$_.EdgeTraversalOptions}}
	
	$RuleHash.Add($Rule.Name, $Properties)
}
$Networks = @{"networks" = $RuleHash} | ConvertTo-Json | Out-File -FilePath $Path