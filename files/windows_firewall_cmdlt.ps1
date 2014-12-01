function Build-PuppetFirewallRule {
    param
    (
        [ValidatePattern('^.*$')]
        [string]$Name = '',
        [string]$Description = '',
        [string]$ApplicationName = '',
        [string]$ServiceName = '',
        [ValidatePattern('^(ICMPv4|IGMP|TCP|UDP|IPv6|IPv6Route|IPv6Frag|GRE|ICMPv6|IPv6NoNxt|IPv6Opts|VRRP|PGM|L2TP|1|2|6|17|41|43|44|47|58|59|60|112|113|115)$')]
        [string]$Protocol = 'TCP',
        [string]$LocalPorts = '',
        [string]$RemotePorts = '',
        [string]$LocalAddresses = '',
        [string]$RemoteAddresses = '',
        [string]$IcmpTypesAndCodes = '',
        [ValidatePattern('^(In|Out|1|2)$')]
        [string]$Direction = 'In',
        [string]$Interfaces = '',
        [ValidatePattern('^(((Wireless|Lan|RemoteAccess)(,(?!$))?(?!\3)){1,2}|All)$')]
        [string]$InterfaceTypes = 'All',
        [ValidatePattern('^(True|False)$')]
        [string]$Enabled = 'True',
        [string]$Grouping = '',
        [ValidatePattern('^(((Domain|Private|Public)(,(?!$))?(?!.*\3)){1,3}|1|2|3|4|5|6|7|2147483647)$')]
        [string]$Profiles = 'Domain,Private,Public',
        [ValidatePattern('^(True|False)$')]
        [string]$EdgeTraversal = 'False',
        [ValidatePattern('^(Allow|Block|1|0)$')]
        [string]$Action = 'Allow',
        [ValidatePattern('^(Block|Allow|Defer to App|Defer to User|0|1|2|3)$')]
        [string]$EdgeTraversalOptions = 'Block'
    )
    
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
    #New-Object -TypeName PSObject -Property @{Rule = $Rule; Ensure = $Ensure}
	$Rule
}

function Get-PuppetFirewallRule
{
    param
    (
        [string]$RuleName
    )
    
    $Firewall = New-Object -ComObject HNetCfg.FwPolicy2
    $Firewall.Rules | where { $_.Name -eq $RuleName }
}

function Validate-PuppetFirewallRule
{
    param
    (
        $Rule,
        $SystemRule
    )

    foreach($PropertyName in ($Rule | Get-Member).Name)
    {
        foreach($Item in $SystemRule)
        {
            if($Item.$PropertyName -ne $Rule.$PropertyName)
            {
                return $false
            }
        }
    }
	
    return $true
}

function Set-PuppetFirewallRule {
    param
    (
        $Rule,
        $SystemRule
    )

    foreach($PropertyName in ($Rule | Get-Member).Name)
    {
        foreach($Item in $SystemRule)
        {
            if($Item.$PropertyName -ne $Rule.$PropertyName)
            {
                $Item.$PropertyName = $Rule.$PropertyName
            }
        }
    }
}

function Prune-PuppetFirewallRule
{
    param
    (
        [string]$RuleName,
        [int]$RuleCount
    )

    $Firewall = New-Object -ComObject HNetCfg.FwPolicy2
    for($i = 2; $i -le $RuleCount; $i++)
    {
        $Firewall.Rules.Remove($RuleName)
    }
}

function Ensure-PuppetFirewallRulePresent {
    param
    (
        $Rule
    )
	
	$SystemRule = Get-PuppetFirewallRule -RuleName $Rule.Name
    if($SystemRule)
    {
        if(!(Validate-PuppetFirewallRule -Rule $Rule -SystemRule $SystemRule))
        {
			Set-PuppetFirewallRule -Rule $Rule -SystemRule $SystemRule
        }
		
        if($SystemRule.Count -gt 1)
        {
            Prune-PuppetFirewallRule -RuleName $Rule.Name -RuleCount $SystemRule.Count
        }
    }
    else
    {
        $Firewall = New-Object -ComObject HNetCfg.FwPolicy2
        $Firewall.Rules.Add($Rule)
    }
}

function Ensure-PuppetFirewallRuleAbsent {
    param
    (
        $RuleName
    )

    $SystemRule = Get-PuppetFirewallRule -RuleName $RuleName
    if($SystemRule)
    {
        $Firewall = New-Object -ComObject HNetCfg.FwPolicy2
        for($i = 1; $i -le $SystemRule.Count; $i++)
        {
            $Firewall.Rules.Remove($Rule.Name)
        }
    }
}

function Disable-SystemFirewallRule
{
    param
    (
        [String[]]$PuppetRules
    )

    $Firewall = New-Object -ComObject HNetCfg.FwPolicy2
    $SystemRules = ($Firewall.rules | where {$_.Direction -eq 1 -and $_.Enabled -eq "True"}).Name
    $RogueRules = (Compare-Object -ReferenceObject $CatalogRules -DifferenceObject $SystemRules).InputObject
    if($RogueRules)
    {
        foreach($RogueRule in $RogueRules)
        {
            $Firewall.Rules | where {$_.Name -eq $RogueRule} | foreach {$_.Enabled = $false}
        }
    }
}