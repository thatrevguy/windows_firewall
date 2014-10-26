#Load rule values template using erb
<%= scope.function_template(["windows_firewall/rule_object.ps1"]) %>

#Remove all rules with matching name
for($i = 1; $i -le $FoundRules.Count; $i++){$Firewall.Rules.Remove($Rule.Name)}