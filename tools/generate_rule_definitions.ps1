#This script can help you get started with a baseline json hiera data source.
#Just run it on a Windows system with preferred firewall rules already created and enabled through advfirewall.
$Path = 'C:\firewall_rules.json'
$SystemRules = (New-Object -ComObject HNetCfg.FwPolicy2).Rules

#Would use get-member but it does not preserve original object attribute order.
#You can define attributes in your json/yaml hiera data source out of order if you wish.
#'firewall_rule' custom type will ensure proper order before building rule objects with 'rule' provider.
$AttrNames = ((New-Object -ComObject HNetCfg.FwRule | ConvertTo-Csv)[1].split(',') -replace '"', '')

#Make sure system rules that you are generating this json for all have UNIQUE names.
#This is a must as duplicate keys are not allowed and windows_firewall module prunes duplicate names caught on advfirewall.
#This script will append any subsequent duplicate names with an integer value in order found.
$RuleHash = New-Object System.Collections.Specialized.OrderedDictionary

foreach($SystemRule in ($SystemRules | where {$_.enabled -eq $true} | Sort-Object -Property Name))
{
  $AttrHash = New-Object System.Collections.Specialized.OrderedDictionary
  foreach($AttrName in $AttrNames[1..$AttrNames.Count])
  {
    $AttrValue = $SystemRule.$AttrName
    if ($AttrValue)
{
      while($AttrName -cmatch "^.*[a-z](?=[A-Z])")
      {
        $AttrName = $AttrName.Insert($Matches[0].Length, '_')
      }

      $AttrHash.add($AttrName.toLower(), $AttrValue)
}
  }

  if($RuleHash[$SystemRule.Name] -ne $Null)
  {
    $Count = ($RuleHash.Keys -cmatch "^$([regex]::Escape($SystemRule.Name))\s\d.*$").Count + 1
    $RuleHash.add("$($SystemRule.Name) $Count" , $AttrHash)
  }
  else
  {
    $RuleHash.add($SystemRule.Name, $AttrHash)
  }
}

#ConvertTo-Json has terrible white space issues unless you compress output which then makes it unreadable.
$JSON = @{'windows_networks' = $RuleHash} | ConvertTo-Json
$JSON = $JSON -split "\n"
$JSON = $JSON | foreach{$_ -replace "^\s+", ''}
$JSON = $JSON | foreach{$_ -replace ":\s+(?=({|`"|\d|\w))", ': '}
for($x=0; $x -lt 2; $x++){$i=0; $JSON = $JSON | foreach{if($i -gt $x -and $i -lt $JSON.Count-1-$x){$_.Insert(0, '  '); $i++}else{$_; $i++}}}
$JSON = $JSON | foreach{if($_ -match "^\s+`".*`":\s(?!{)"){$_.Insert(0, '  ')}else{$_}}
$JSON -join "" | Out-File $Path -Encoding ascii