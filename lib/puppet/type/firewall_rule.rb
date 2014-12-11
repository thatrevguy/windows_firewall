# lib/puppet/type/firewall_rule.rb
Puppet::Type.newtype(:firewall_rule) do
  @doc = "Define Windows advanced firewall rules."

  newparam(:name) do
    desc "Name."
	isnamevar
  end

  newparam(:enabled) do
    if value
      if @resource.provider and @resource.provider.respond_to?(:create)
          @resource.provider.create
      else
          @resource.create
      end
      nil
    end
  end

  newproperty(:rule_hash) do
    desc "Apply firewall rule hash from Hiera."

    validation_hash = Hash.new()
	validation_hash['ensure'] = /^(present|absent)$/i
    validation_hash['protocol'] = /^(ICMPv4|IGMP|TCP|UDP|IPv6|IPv6Route|IPv6Frag|GRE|ICMPv6|IPv6NoNxt|IPv6Opts|VRRP|PGM|L2TP|1|2|6|17|41|43|44|47|58|59|60|112|113|115)$/i
    validation_hash['direction'] = /^(In|Out|1|2)$/i
    validation_hash['interface_types'] = /^(((Wireless|Lan|RemoteAccess)(,(?!$))?(?!\3)){1,2}|All)$/i
    validation_hash['enabled'] = /^(True|False)$/i
    validation_hash['profiles'] = /^(((Domain|Private|Public)(,(?!$))?(?!.*\3)){1,3}|1|2|3|4|5|6|7|2147483647)$/i
    validation_hash['edge_traversal'] = /^(True|False)$/i
    validation_hash['action'] = /^(Allow|Block|1|0)$/i
    validation_hash['edge_traversal_options'] = /^(Block|Allow|Defer to App|Defer to User|0|1|2|3)$/i

    validate do |value|
      value.each do |name, rule|
        validation_hash.keys.each do |key|
          if rule[key]
            message = "Rule \'%s\' %s attribute value of \'%s\' is invalid." % [name, key, rule[key].to_s]
            raise ArgumentError, message if rule[key].to_s !~ validation_hash[key]
          end
        end
      end
    end
  end
end