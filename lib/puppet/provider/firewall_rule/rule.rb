require 'win32ole'

class Firewall
  @system_rules = WIN32OLE.new("HNetCfg.FwPolicy2").rules

  def self.getrules(rules)
    @system_rules.each do |rule|
      puts rule.name
	end
  end
end

Puppet::Type.type(:firewall_rule).provide(:rule) do
  desc "Configures rules"
  
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

  def create
  end
  
  def destroy
  end
  
  def exists?
    true
  end
  
  def rule_hash
  
    #@resource.should(:rule_hash)
  end
  
  def rule_hash=(value)
    
  end
end