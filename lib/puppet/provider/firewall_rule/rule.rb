require 'win32ole'

Puppet::Type.type(:firewall_rule).provide(:rule) do
  desc "Configures rules"

  system_rules = WIN32OLE.new("HNetCfg.FwPolicy2")

  attr_hash = Hash.new()
  attr_hash['ensure'] = [nil, 'present']
  attr_hash['description'] = ['Description', '']
  attr_hash['application_name'] = ['ApplicationName', '']
  attr_hash['service_name'] = ['serviceName', '']
  attr_hash['protocol'] = ['Protocol', 'TCP']
  attr_hash['local_ports'] = ['LocalPorts', '']
  attr_hash['remote_ports'] = ['RemotePorts', '']
  attr_hash['local_addresses'] = ['LocalAddresses', '']
  attr_hash['remote_addresses'] = ['RemoteAddresses', '']
  attr_hash['icmp_types_and_codes'] = ['IcmpTypesAndCodes', '']
  attr_hash['direction'] = ['Direction', 'In']
  attr_hash['interfaces'] = ['Interfaces', nil]
  attr_hash['interface_types'] = ['InterfaceTypes', 'All']
  attr_hash['enabled'] = ['Enabled', 'True']
  attr_hash['grouping'] = ['Grouping', '']
  attr_hash['profiles'] = ['Profiles', 'Domain,Private,Public']
  attr_hash['edge_traversal'] = ['EdgeTraversal', 'False']
  attr_hash['action'] = ['Action', 'Allow']
  attr_hash['edge_traversal_options'] = ['EgdeTraversalOptions', 'Block']

  #Get system rules
  def get_rules
    system_rules.rules.each do |rule|
      puts rule.name
    end
  end

  def create
    get_rules
  end

  def rule_hash
    should_rules = @resource.should(:rule_hash)
	
	rule_hash = 1
  end
  
  def rule_hash=(value)
    create
  end
end