# lib/puppet/type/firewall_rule.rb
require 'digest/md5'

def munge_parser(value, hash)
  if hash != nil
    if hash[value]
      return hash[value]
    else
      return value
    end
  else
    return value
  end
end

def int_check(value)
  intvalue = Integer(value) rescue nil
  if intvalue
    return intvalue
  end

  return value
end

Puppet::Type.newtype(:firewall_rule) do
  @doc = "Defines Windows advanced firewall rule attributes."

  ensurable
  
  newparam(:name, :namevar => true) do
    desc "Firewall rule name."
  end 

  newproperty(:description) do
    desc "Rule description attribute."
  end

  newproperty(:application_name) do
    desc "Rule application name attribute."
  end

  newproperty(:service_name) do
    desc "Rule service name attribute."
  end

  newproperty(:protocol) do
    desc "Rule protocol attribute."
    validate do |value|
      validation_set = /^(ICMPv4|IGMP|TCP|UDP|IPv6|IPv6Route|IPv6Frag|GRE|ICMPv6|IPv6NoNxt|IPv6Opts|VRRP|PGM|L2TP|1|2|6|17|41|43|44|47|58|59|60|112|113|115)$/i
      message = "Property value of #{value} is invalid."
      raise ArgumentError, message if value.to_s !~ validation_set
    end

    munge do |value|
      value = int_check(value)
      hash = { 'ICMPv4'=>1, 'IGMP'=>2, 'TCP'=>6, 'UDP'=>17, 'IPv6'=>41, 'IPv6Route'=>43, 'IPv6Frag'=>44, 'GRE'=>47, 'ICMPv6'=>58, 'IPv6NoNxt'=>59, 'IPv6Opts'=>60, 'VRRP'=>112, 'PGM'=>113, 'L2TP'=>115 }
      value = munge_parser(value, hash)
    end
  end

  newproperty(:local_ports) do
    desc "Rule local ports attribute."
  end

  newproperty(:remote_ports) do
    desc "Rule remote ports attribute."
  end

  newproperty(:local_addresses) do
    desc "Rule local addresses attribute."
  end

  newproperty(:remote_addresses) do
    desc "Rule remote addresses attribute."
  end

  newproperty(:icmp_types_and_codes) do
    desc "Rule icmp types and codes attribute."
  end

  newproperty(:direction) do
    desc "Rule direction attribute."
    validate do |value|
      validation_set = /^(In|Out|1|2)$/i
      message = "Property value of #{value} is invalid."
      raise ArgumentError, message if value.to_s !~ validation_set
    end

    munge do |value|
      value = int_check(value)
      hash = { 'In'=>1, 'Out'=>2 }
      value = munge_parser(value, hash)
    end
  end

  newproperty(:interfaces) do
    desc "Rule interfaces attribute."
  end

  newproperty(:interface_types) do
    desc "Rule interface types attribute."
    validate do |value|
      validation_set = /^(((Wireless|Lan|RemoteAccess)(,(?!$))?(?!\3)){1,2}|All)$/i
      message = "Property value of #{value} is invalid."
      raise ArgumentError, message if value.to_s !~ validation_set
    end

    munge do |value|
      newval = []
      value.split(',').each do |string|
        newval << string.capitalize
      end

      return newval.join(',')
    end
  end

  newproperty(:enabled) do
    desc "Rule enabled attribute."
  end

  newproperty(:grouping) do
    desc "Rule grouping attribute."
  end

  newproperty(:profiles) do
    desc "Rule profiles attribute."
    validate do |value|
      validation_set = /^(((Domain|Private|Public)(,(?!$))?(?!.*\3)){1,3}|1|2|3|4|5|6|7|2147483647)$/i
      message = "Property value of #{value} is invalid."
      raise ArgumentError, message if value.to_s !~ validation_set
    end
	
    munge do |value|
      value = int_check(value)
      hash = { 'Domain'=>1, 'Private'=>2, 'Public'=>4 }
      unless value.is_a? Integer
        i = 0
        value.split(',').each do |profile|
          i += hash[profile]
        end
      
        if i == 7
          i = 2147483647
        end
      
        return i
      else  
        return value
      end
    end
  end

  newproperty(:edge_traversal) do
    desc "Rule edge traversal attribute."
  end

  newproperty(:action) do
    desc "Rule action attribute."
    validate do |value|
      validation_set = /^(Allow|Block|1|0)$/i
      message = "Property value of #{value} is invalid."
      raise ArgumentError, message if value.to_s !~ validation_set
    end

    munge do |value|
      value = int_check(value)
      hash = { 'Allow'=>1, 'Block'=>0 }
      value = munge_parser(value, hash)
    end
  end

  newproperty(:edge_traversal_options) do
    desc "Rule edge traversal options attribute."
    validate do |value|
      validation_set = /^(Block|Allow|Defer to App|Defer to User|0|1|2|3)$/i
      message = "Property value of #{value} is invalid."
      raise ArgumentError, message if value.to_s !~ validation_set
    end

    munge do |value|
      value = int_check(value)
      hash = { 'Block'=>0, 'Allow'=>1, 'Defer to App'=>2, 'Defer to User'=>3 }
      value = munge_parser(value, hash)
    end
  end
end