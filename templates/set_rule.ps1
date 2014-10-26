#Load rule values template using erb
<%= scope.function_template(["windows_firewall/rule_object.ps1"]) %>

#Update rule property values that are different.
foreach($PropertyName in ($Rule | Get-Member).Name){foreach($FoundRule in $FoundRules){if($FoundRule.$PropertyName -ne $Rule.$PropertyName){ $FoundRule.$PropertyName = $Rule.$PropertyName }}}