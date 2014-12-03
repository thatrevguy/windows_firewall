<%= scope.function_template(["windows_firewall/generate_rules.ps1"]) %>
if($PresentPuppetRules){Disable-SystemFirewallRule -PuppetRules $PresentPuppetRules.Name -PuppetValidation}
$PresentPuppetRules | foreach {Ensure-PuppetFirewallRulePresent -Rule $_ -PuppetValidation}
$AbsentPuppetRules | foreach {Ensure-PuppetFirewallRuleAbsent -RuleName $_ -PuppetValidation}