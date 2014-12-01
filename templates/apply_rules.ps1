Import-Module "C:\ProgramData\PuppetLabs\puppet\var\files\windows_firewall_cmdlt.ps1"
$PuppetRules = @()

#Apply rules
<% @networks.sort.each do |key, network| -%>
    <%- if network['ensure'] != "absent" -%>
        $Rule = Build-PuppetFirewallRule `
            <%- if network['description'] -%>-Description "<%= network['description'] %>" `<%- puts "\r\n" -%><%- end -%>
            <%- if network['application_name'] -%>-ApplicationName '<%= network['application_name'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['service_name'] -%>-ServiceName '<%= network['service_name'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['protocol'] -%>-Protocol '<%= network['protocol'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['local_ports'] -%>-LocalPorts '<%= network['local_ports'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['remote_ports'] -%>-RemotePorts '<%= network['remote_ports'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['local_addresses'] -%>-LocalAddresses '<%= network['local_addresses'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['remote_addresses'] -%>-RemoteAddresses '<%= network['remote_addresses'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['icmp_types_and_codes'] -%>-IcmpTypesAndCodes '<%= network['icmp_types_and_codes'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['direction'] -%>-Direction '<%= network['direction'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['interfaces'] -%>-Interfaces '<%= network['interfaces'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['interface_types'] -%>-InterfaceTypes '<%= network['interface_types'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['enabled'] -%>-Enabled '<%= network['enabled'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['grouping'] -%>-Grouping '<%= network['grouping'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['profiles'] -%>-Profiles '<%= network['profiles'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['edge_traversal'] -%>-EdgeTraversal '<%= network['edge_traversal'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['action'] -%>-Action '<%= network['action'] %>' `<%- puts "\r\n" -%><%- end -%>
            <%- if network['edge_traversal_options'] -%>-EdgeTraversalOptions '<%= network['edge_traversal_options'] %>' `<%- puts "\r\n" -%><%- end -%>
            -Name '<%= key %>'
        Ensure-PuppetFirewallRulePresent -Rule $Rule
        $PuppetRules += '<%= key %>'
    <%- else -%>
        Ensure-PuppetFirewallRuleAbsent -RuleName '<%= key %>'
    <%- end -%>
<% end -%>

#Disable system rules not in puppet
if($PuppetRules){Disable-SystemFirewallRule -PuppetRules $PuppetRules}