#Import-Module "C:\ProgramData\PuppetLabs\puppet\var\files\windows_firewall_cmdlt.ps1"
$PuppetRules = @()

#Apply rules
<% @networks.sort.each do |key, network| -%>
    <%- if network['ensure'] == "present" -%>
        $Rule = Build-PuppetFirewallRule `
            <%- if network['description'] -%>-Description '<%= network['description'] %>' `<%- end -%>
            -Name '<%= key %>'
        Ensure-PuppetFirewallRulePresent -Rule $Rule
        $PuppetRules += '<%= key %>'
	<%- else -%>
        Ensure-PuppetFirewallRuleAbsent -RuleName '<%= key %>'
	<%- end -%>
<% end -%>

#Disable system rules not in puppet
if($PuppetRules){Disable-SystemFirewallRule -PuppetRules $PuppetRules}