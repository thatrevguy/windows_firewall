#Load rule values template using erb
<%= scope.function_template(["windows_firewall/rule_object.ps1"]) %>

#Check if rule name exists
$CheckType = '<%= @check_type %>'
if($CheckType -eq 'Ensure'){if($FoundRules.Count -ne 0){ exit 1 }}else{if($FoundRules.Count -gt 1){ exit 1 }}