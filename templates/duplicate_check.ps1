#Load rule values template using erb
<%= scope.function_template(["windows_firewall/rule_object.ps1"]) %>

#Check if rule name exists
if($FoundRules.Count -gt 1){ exit 1 }