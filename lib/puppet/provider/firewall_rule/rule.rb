require 'win32ole'
Puppet::Type.type(:firewall_rule).provide(:rule) do
  desc "Operate on rules for ensurable"

  system_rules = WIN32OLE.new("HNetCfg.FwPolicy2").rules
  system_rules.each do |system_rule|
    puts system_rule.name
  end
  
  def rule_hash
    rule_attr = Hash.new()
    rule_attr['ensure'] = [nil, 'present']
    rule_attr['description'] = ['Description', '']
    rule_attr['application_name'] = ['ApplicationName', '']
    rule_attr['service_name'] = ['serviceName', '']
    rule_attr['protocol'] = ['Protocol', 'TCP']
    rule_attr['local_ports'] = ['LocalPorts', '']
    rule_attr['remote_ports'] = ['RemotePorts', '']
    rule_attr['local_addresses'] = ['LocalAddresses', '']
    rule_attr['remote_addresses'] = ['RemoteAddresses', '']
    rule_attr['icmp_types_and_codes'] = ['IcmpTypesAndCodes', '']
    rule_attr['direction'] = ['Direction', 'In']
    rule_attr['interfaces'] = ['Interfaces', nil]
    rule_attr['interface_types'] = ['InterfaceTypes', 'All']
    rule_attr['enabled'] = ['Enabled', 'True']
    rule_attr['grouping'] = ['Grouping', '']
    rule_attr['profiles'] = ['Profiles', 'Domain,Private,Public']
    rule_attr['edge_traversal'] = ['EdgeTraversal', 'False']
    rule_attr['action'] = ['Action', 'Allow']
    rule_attr['edge_traversal_options'] = ['EgdeTraversalOptions', 'Block']
	
    should_rule = @resource.should(:rule_hash)
	puts should_rule
  end
  
  def rule_hash=(value)
  
  end
end