#Collect variables in current scope using erb
$Name = '<%= @display_name %>'
$Description = '<%= @description %>'
$ApplicationName = '<%= @application_name %>'
$ServiceName = '<%= @service_name %>'
$Protocol = '<%= @protocol %>'
$LocalPorts = '<%= @local_ports %>'
$RemotePorts = '<%= @remote_ports %>'
$LocalAddresses = '<%= @local_addresses %>'
$RemoteAddresses = '<%= @remote_addresses %>'
$IcmpTypesAndCodes = '<%= @icmp_types_and_codes %>'
$Direction = '<%= @direction %>'
$Interfaces = '<%= @interfaces %>'
$InterfaceTypes = '<%= @interface_types %>'
$Enabled = '<%= @enabled %>'
$Grouping = '<%= @grouping %>'
$Profiles = '<%= @profiles %>'
$EdgeTraversal = '<%= @edge_traversal %>'
$Action = '<%= @action %>'
$EdgeTraversalOptions = '<%= @edge_traversal_options %>'

#Convert protocol string to int
$ProtocolHash = @{"ICMPv4"=1;"IGMP"=2;"TCP"=6;"UDP"=17;"IPv6"=41;"IPv6Route"=43;"IPv6Frag"=44;"GRE"=47;"ICMPv6"=48;"IPv6NoNxt"=59;"IPv6Opts"=60;"VRRP"=112; "PGM"=113;"L2TP"=115}
$Protocol = $ProtocolHash.Get_Item($Protocol)

#Convert direction string to int
$DirectionHash = @{"In"=1;"Out"=2}
$Direction = $DirectionHash.Get_Item($Direction)

#Convert interfaces string to array or null
#Will only accept a good ole' fashioned array.
if($Interfaces.Length -ne 0){ $InterfacesArray = $Interfaces.Split(','); $Interfaces = New-Object System.Object[] $InterfacesArray.Count; for($i = 0; $i -lt $InterfacesArray.Count; $i++){$Interfaces.Set($i,$InterfacesArray[$i])} }else{$Interfaces = @()}

#Convert profiles string to int
$ProfileHash = @{"Domain"=1;"Private"=2;"Public"=4}
$i = 0
foreach($Profile in $Profiles.Split(",")){$i = $i + $ProfileHash.Get_Item($Profile)}
if($i -eq 7){$Profiles = 2147483647}else{$Profiles = $i}

#Convert enabled to bool
if($Enabled -eq "True"){$Enabled = $true}else{$Enabled = $false}

#Convert action string to int
$ActionHash = @{"Allow"=1;"Block"=0}
$Action = $ActionHash.Get_Item($Action)

#Convert egde_traversal string to bool
if($EdgeTraversal -eq "True"){$EdgeTraversal = $true}else{$EdgeTraversal = $false}

#Convert edge_traversal_options string to int
$EdgeTraversalOptionsHash = @{"Block"=0;"Allow"=1;"Defer to App"=2;"Defer to User"=3}
$EdgeTraversalOptions = $EdgeTraversalOptionsHash.Get_Item($EdgeTraversalOptions)

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
$RuleProperties.Add("LocalAppPackageId", '')
$RuleProperties.Add("LocalUserOwner", '')
$RuleProperties.Add("LocalUserAuthorizedList", '')
$RuleProperties.Add("RemoteUserAuthorizedList", '')
$RuleProperties.Add("RemoteMachineAuthorizedList", '')
$RuleProperties.Add("SecureFlags", 0)

#Build rule object
$Rule = New-Object -ComObject HNetCfg.FWRule
foreach($Key in $RuleProperties.Keys){if($RuleProperties.Get_Item($Key) -ne ''){$Rule.$Key = $RuleProperties.Get_Item($Key)}}

#Found system rule
$Firewall = New-Object -ComObject HNetCfg.FwPolicy2
$FoundRules = $Firewall.Rules | where { $_.Name -eq $Rule.Name }