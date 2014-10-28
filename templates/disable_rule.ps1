#Disable any rules not defined in catalog.
$CatalogPath = "$env:ProgramData\PuppetLabs\puppet\var\client_data\catalog"
$WindowsFirewall = New-Object -ComObject HNetCfg.FWPolicy2
$CatalogRuleNames = ((Get-Content -Path $CatalogPath\*.json | ConvertFrom-Json).Data.Resources | Where {$_.Type -eq "Windows_firewall::Rule"}).Title
$SystemRuleNames = ($WindowsFirewall.rules | where {$_.Direction -eq 1 -and $_.Enabled -eq "True"}).Name
$RogueRules = (Compare-Object -ReferenceObject $CatalogRuleNames -DifferenceObject $SystemRuleNames).InputObject
if($RogueRules){$RogueRules | foreach {$Name = $_; $WindowsFirewall.Rules | where {$_.Name -eq $Name} | foreach {$_.Enabled = $false}}}