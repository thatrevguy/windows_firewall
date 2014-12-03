<%= scope.function_template(["windows_firewall/generate_rules.ps1"]) %>
#Add rules
$PresentPuppetRules | foreach {Ensure-PuppetFirewallRulePresent -Rule $_}
#Remove rules
$AbsentPuppetRules | foreach {Ensure-PuppetFirewallRuleAbsent -RuleName $_}
#Disable system rules not in puppet
if($PresentPuppetRules){Disable-SystemFirewallRule -PuppetRules $PresentPuppetRules.Name}