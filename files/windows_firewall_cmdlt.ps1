function Build-PuppetFirewallRule {
	param
	(
		[json]$RuleDef
	)
	
	$RuleDef = $RuleDef.Split('|')

	$Ensure = $RuleProperties[0]
	$Name = $RuleProperties[1]
	$Description = $RuleProperties[2]
	$ApplicationName = $RuleProperties[3]
	$ServiceName = $RuleProperties[4]
	$Protocol = $RuleProperties[5]
	$LocalPorts = $RuleProperties[6]
	$RemotePorts = $RuleProperties[7]
	$LocalAddresses = $RuleProperties[8]
	$RemoteAddresses = $RuleProperties[9]
	$IcmpTypesAndCodes = $RuleProperties[10]
	$Direction = $RuleProperties[11]
	$Interfaces = $RuleProperties[12]
	$InterfaceTypes = $RuleProperties[13]
	$Enabled = $RuleProperties[14]
	$Grouping = $RuleProperties[15]
	$Profiles = $RuleProperties[16]
	$EdgeTraversal = $RuleProperties[17]
	$Action = $RuleProperties[18]
	$EdgeTraversalOptions = $RuleProperties[19]	
	
	#Convert protocol string to int
	$ProtocolHash = @{"ICMPv4"=1;"IGMP"=2;"TCP"=6;"UDP"=17;"IPv6"=41;"IPv6Route"=43;"IPv6Frag"=44;"GRE"=47;"ICMPv6"=58;"IPv6NoNxt"=59;"IPv6Opts"=60;"VRRP"=112; "PGM"=113;"L2TP"=115}
	if($ProtocolHash.Get_Item($Protocol)){$Protocol = $ProtocolHash.Get_Item($Protocol)}
	
	#Convert direction string to int
	$DirectionHash = @{"In"=1;"Out"=2}
	if($DirectionHash.Get_Item($Direction)){$Direction = $DirectionHash}
	
	#Convert interfaces string to array or null
	#Will only accept a good ole' fashioned array.
	if($Interfaces.Length -ne ''){ $InterfacesArray = $Interfaces.Split(','); $Interfaces = New-Object System.Object[] $InterfacesArray.Count; for($i = 0; $i -lt $InterfacesArray.Count; $i++){$Interfaces.Set($i,$InterfacesArray[$i])} }else{$Interfaces = @()}
	
	#Convert profiles string to int
	$ProfileHash = @{"Domain"=1;"Private"=2;"Public"=4}
	$i = 0
	foreach($Profile in $Profiles.Split(",")){$i = $i + $ProfileHash.Get_Item($Profile)}
	if($i -eq 7){$Profiles = 2147483647}elseif($i -ne 0){$Profiles = $i}
	
	#Convert enabled to bool
	if($Enabled -eq "True"){$Enabled = $true}else{$Enabled = $false}
	
	#Convert action string to int
	$ActionHash = @{"Allow"=1;"Block"=0}
	if($ActionHash.Get_Item($Action)){$Action = $ActionHash.Get_Item($Action)}
	
	#Convert egde_traversal string to bool
	if($EdgeTraversal -eq "True"){$EdgeTraversal = $true}else{$EdgeTraversal = $false}
	
	#Convert edge_traversal_options string to int
	$EdgeTraversalOptionsHash = @{"Block"=0;"Allow"=1;"Defer to App"=2;"Defer to User"=3}
	if($EdgeTraversalOptionsHash.Get_Item($EdgeTraversalOptions)){$EdgeTraversalOptions = $EdgeTraversalOptionsHash.Get_Item($EdgeTraversalOptions)}
	
	#Build hash table with all rule properties
	$RuleProperties = [System.Collections.Specialized.OrderedDictionary]@{}
	$RuleProperties.Add("Name", $Name) 
	$RuleProperties.Add("Description", $Description)
	$RuleProperties.Add("ApplicationName", $ApplicationName)
	$RuleProperties.Add("ServiceName", $ServiceName)
	$RuleProperties.Add("Protocol", $Protocol)
	$RuleProperties.Add("LocalPorts", $LocalPorts)
	$RuleProperties.Add("RemotePorts", $RemotePorts)
	$RuleProperties.Add("LocalAddresses", $LocalAddresses)
	$RuleProperties.Add("RemoteAddresses", $RemoteAddresses)
	$RuleProperties.Add("IcmpTypesAndCodes", $IcmpTypesAndCodes)
	$RuleProperties.Add("Direction", $Direction)
	$RuleProperties.Add("Interfaces", $Interfaces)
	$RuleProperties.Add("InterfaceTypes", $InterfaceTypes)
	$RuleProperties.Add("Enabled", $Enabled)
	$RuleProperties.Add("Grouping", $Grouping)
	$RuleProperties.Add("Profiles", $Profiles)
	$RuleProperties.Add("EdgeTraversal", $EdgeTraversal)
	$RuleProperties.Add("Action", $Action)
	$RuleProperties.Add("EdgeTraversalOptions", $EdgeTraversalOptions)
	#Below lines are Server 2012 compatable only.
	#$RuleProperties.Add("LocalAppPackageId", '')
	#$RuleProperties.Add("LocalUserOwner", '')
	#$RuleProperties.Add("LocalUserAuthorizedList", '')
	#$RuleProperties.Add("RemoteUserAuthorizedList", '')
	#$RuleProperties.Add("RemoteMachineAuthorizedList", '')
	#$RuleProperties.Add("SecureFlags", 0)
	
	#Build rule object
	$Rule = New-Object -ComObject HNetCfg.FWRule
	foreach($Key in $RuleProperties.Keys){if($RuleProperties.Get_Item($Key) -ne ''){$Rule.$Key = $RuleProperties.Get_Item($Key)}}
	$Rule
}

function Add-PuppetFirewallRule {
	
}

	#Found system rule
	$Firewall = New-Object -ComObject HNetCfg.FwPolicy2
	$FoundRules = $Firewall.Rules | where { $_.Name -eq $Rule.Name }