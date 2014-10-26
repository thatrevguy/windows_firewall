#Load rule values template using erb
<%= scope.function_template(["windows_firewall/rule_object.ps1"]) %>

#Check if rule property values match
foreach($PropertyName in ($Rule | Get-Member).Name){foreach($FoundRule in $FoundRules){if($FoundRule.$PropertyName -ne $Rule.$PropertyName){ "Property value mismatch!" | Out-File C:\PuppetMessage.txt; exit 1 }}}