# lib/puppet/type/firewall_rule.rb
Puppet::Type.newtype(:firewall_rule) do
  @doc = "Define Windows advanced firewall rules."

  newparam(:name) do
    desc "Name."
	isnamevar
  end

  newproperty(:rule_hash) do
    desc "Apply firewall rule hash from Hiera."

    rule_attr_name = Hash.new()
    rule_attr_name['description'] = [nil, 'Description', nil]
    rule_attr_name['application_name'] = [nil, 'ApplicationName', nil]
    rule_attr_name['service_name'] = [nil, 'serviceName', nil]
    rule_attr_name['protocol'] = [/^(ICMPv4|IGMP|TCP|UDP|IPv6|IPv6Route|IPv6Frag|GRE|ICMPv6|IPv6NoNxt|IPv6Opts|VRRP|PGM|L2TP|1|2|6|17|41|43|44|47|58|59|60|112|113|115)$/i, 'Protocol', 'TCP']
    rule_attr_name['local_ports'] = [nil, 'LocalPorts', nil]
    rule_attr_name['remote_ports'] = [nil, 'RemotePorts', nil]
    rule_attr_name['local_addresses'] = [nil, 'LocalAddresses', nil]
    rule_attr_name['remote_addresses'] = [nil, 'RemoteAddresses', nil]
    rule_attr_name['icmp_types_and_codes'] = [nil, 'IcmpTypesAndCodes', nil]
    rule_attr_name['direction'] = [/^(In|Out|1|2)$/i, 'Direction', 'In']
    rule_attr_name['interfaces'] = [nil, 'Interfaces', nil]
    rule_attr_name['interface_types'] = [/^(((Wireless|Lan|RemoteAccess)(,(?!$))?(?!\3)){1,2}|All)$/i, 'InterfaceTypes', 'All']
    rule_attr_name['enabled'] = [/^(True|False)$/i, 'Enabled', 'True']
    rule_attr_name['grouping'] = [nil, 'Grouping', nil]
    rule_attr_name['profiles'] = [/^(((Domain|Private|Public)(,(?!$))?(?!.*\3)){1,3}|1|2|3|4|5|6|7|2147483647)$/i, 'Profiles', 'Domain,Private,Public']
    rule_attr_name['edge_traversal'] = [/^(True|False)$/i, 'EdgeTraversal', 'False']
    rule_attr_name['action'] = [/^(Allow|Block|1|0)$/i, 'Action', 'Allow']
    rule_attr_name['edge_traversal_options'] = [/^(Block|Allow|Defer to App|Defer to User|0|1|2|3)$/i, 'EgdeTraversalOptions', 'Block']

    validate do |value|
      value.each do |name, rule|
        rule_attr_name.keys.each do |key|
          if rule_attr_name[key][0]
            message = "Rule \'%s\' %s attribute value of \'%s\' is invalid." % [name, key, rule[key].to_s]
            raise ArgumentError, message if rule[key].to_s !~ rule_attr_name[key][0]
          end
        end
      end
    end
  end
end