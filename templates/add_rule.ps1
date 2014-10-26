#Load rule values template using erb
<%= scope.function_template(["windows_firewall/rule_object.ps1"]) %>

#Add Rule
$Firewall.Rules.Add($Rule)