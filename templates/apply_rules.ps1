Import-Module "C:\ProgramData\PuppetLabs\puppet\var\files\windows_firewall_cmdlt.ps1"
$PresentPuppetRules = @()
$AbsentPuppetRules = @()
#Generate Rule Arrays
<% @networks.sort.each do |key, network| -%>
    <%- if network['ensure'] != "absent" -%>
        $Rule = Build-PuppetFirewallRule `
            <% if network['description'] -%>-Description "<%= network['description'] %>" `<%- end %>
            <% if network['application_name'] -%>-ApplicationName '<%= network['application_name'] %>' `<%- end %>
            <% if network['service_name'] -%>-ServiceName '<%= network['service_name'] %>' `<%- end %>
            <% if network['protocol'] -%>-Protocol '<%= network['protocol'] %>' `<%- end %>
            <% if network['local_ports'] -%>-LocalPorts '<%= network['local_ports'] %>' `<%- end %>
            <% if network['remote_ports'] -%>-RemotePorts '<%= network['remote_ports'] %>' `<%- end %>
            <% if network['local_addresses'] -%>-LocalAddresses '<%= network['local_addresses'] %>' `<%- end %>
            <% if network['remote_addresses'] -%>-RemoteAddresses '<%= network['remote_addresses'] %>' `<%- end %>
            <% if network['icmp_types_and_codes'] -%>-IcmpTypesAndCodes '<%= network['icmp_types_and_codes'] %>' `<%- end %>
            <% if network['direction'] -%>-Direction '<%= network['direction'] %>' `<%- end %>
            <% if network['interfaces'] -%>-Interfaces '<%= network['interfaces'] %>' `<%- end %>
            <% if network['interface_types'] -%>-InterfaceTypes '<%= network['interface_types'] %>' `<%- end %>
            <% if network['enabled'] -%>-Enabled '<%= network['enabled'] %>' `<%- end %>
            <% if network['grouping'] -%>-Grouping '<%= network['grouping'] %>' `<%- end %>
            <% if network['profiles'] -%>-Profiles '<%= network['profiles'] %>' `<%- end %>
            <% if network['edge_traversal'] -%>-EdgeTraversal '<%= network['edge_traversal'] %>' `<%- end %>
            <% if network['action'] -%>-Action '<%= network['action'] %>' `<%- end %>
            <% if network['edge_traversal_options'] -%>-EdgeTraversalOptions '<%= network['edge_traversal_options'] %>' `<%- end %>
            -Name '<%= key %>'
        $PresentPuppetRules += $Rule
    <%- else -%>
        $AbsentPuppetRules += '<%= key %>'
    <%- end -%>
<% end -%>
#Send exit code 1 if no diffs found
$PresentPuppetRules | foreach {if(!(Ensure-PuppetFirewallRulePresent -Rule $_ -PuppetValidation)){ exit 1 }}
#Add rules
$PresentPuppetRules | foreach {Ensure-PuppetFirewallRulePresent -Rule $_}
#Remove rules
$AbsentPuppetRules | foreach {Ensure-PuppetFirewallRuleAbsent -RuleName $_}
#Disable system rules not in puppet
if($PresentPuppetRules){Disable-SystemFirewallRule -PuppetRules $PresentPuppetRules.Name}