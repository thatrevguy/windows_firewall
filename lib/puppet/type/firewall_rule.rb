# lib/puppet/type/firewall_rule.rb
require 'digest/md5'

Puppet::Type.newtype(:firewall_rule) do
  @doc = "Define Windows advanced firewall rules."

  newparam(:name) do
    desc "Name."
	isnamevar
  end

  #ensurable do
  #  defaultto(:present)
  #  newvalue(:present) do
  #    provider.create
  #  end
  #end
    newproperty(:apply) do
      newvalues (:true, :false)
    end   

  newproperty(:rule_hash) do
    desc "Apply firewall rule hash from Hiera."

    isrequired

    validation_hash = Hash.new()
	validation_hash['ensure'] = /^(present|absent)$/i
    validation_hash['protocol'] = /^(ICMPv4|IGMP|TCP|UDP|IPv6|IPv6Route|IPv6Frag|GRE|ICMPv6|IPv6NoNxt|IPv6Opts|VRRP|PGM|L2TP|1|2|6|17|41|43|44|47|58|59|60|112|113|115)$/i
    validation_hash['direction'] = /^(In|Out|1|2)$/i
    validation_hash['interface_types'] = /^(((Wireless|Lan|RemoteAccess)(,(?!$))?(?!\3)){1,2}|All)$/i
    validation_hash['profiles'] = /^(((Domain|Private|Public)(,(?!$))?(?!.*\3)){1,3}|1|2|3|4|5|6|7|2147483647)$/i
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

    #Below methods and munging designed to replicate values that would be returned by HNetCfg.FWRule objects in a hash.
	#Checksum of hash is sent to provider then compared.

    #HNetCfg.FWRule sorts and formats RemoteAddresses and LocalAddresses attribute values.
    #This method attempts to replicate formatting HNetCfg.FWRule performs. 
    #Addresses are sorted unless an address is a range. Ranges are appended in order of entry.
    #Addresses using CIDR are converted to use equivalent netmask value.
    class String
      def is_ip?
        !!IPAddr.new(self) rescue false
      end
    end
    
    def netmask(address, version)
      netmask = address.split('/')
      if netmask[1]
        return IPAddr.new('255.255.255.255').mask(netmask[1]).to_s if version == 4
        return netmask[1] if version == 6
      else
        return '255.255.255.255' if version == 4
        return 64 if version == 6
      end
    end
    
    def addresses(rule_value)
      address_hash = Hash.new()
	  address_hash['local_subnet'] = []
      address_hash['ipv4'] = []
      address_hash['ipv4_range'] = []
      address_hash['ipv6'] = []
      address_hash['ipv6_range'] = []
    
      rule_value.split(',').each do |address|
        if address.is_ip?
          ipaddress = IPAddr.new(address)
          if ipaddress.ipv4?
            address_hash['ipv4'].push("#{ipaddress}/#{netmask(address, 4)}")
          else ipaddress.ipv6?
            address_hash['ipv6'].push("#{ipaddress}/#{netmask(address, 6)}")
          end
        elsif address =~ /^LocalSubnet$/i
          address_hash['local_subnet'].push('LocalSubnet')
        else
          range = Array.new()
          address.split('-').each do |ip|
            range.push(IPAddr.new(ip))
          end
          if range[0].ipv4?
            address_hash['ipv4_range'].push(range.join('-'))
          elsif range[0].ipv6?
            address_hash['ipv6_range'].push(range.join('-'))
          end        
        end
      end
    
      result_array = []
      address_hash.each do |key, value|
        if value
          case key
          when 'ipv4'
            result_array += value.sort_by! {|ip| ip.split('/')[0].split('.').map{ |octet| octet.to_i} }
          when 'ipv6'
            result_array += value.sort
          else
            result_array += value
          end
        end
      end
    
      return result_array.join(',')
    end
    
    #If protocol is not TCP or UDP return port as empty string.
    def ports(protocol, hash_value)
      if [6, 17].include?(protocol) or protocol == nil
        return hash_value
      else
        return ''
      end
    end
    
    #Return equivalent integer value for comma delimited profile names if value is not already an integer.
    def profiles(rule_value, hash)
      unless rule_value.is_a? Integer 
        i = 0
        rule_value.split(',').each do |profile|
          i += hash[1][profile]
        end
    
        if i == 7
          i = hash[0]
        end
    
        return i
      else  
        return rule_value
      end
    end

    def parse_munge_hash(rule_value, hash, key)
      case key
      when 'profiles'
        return profiles(rule_value, hash)
      when /remote_addresses|local_addresses/i
        if rule_value !~ /^(\*|LocalSubnet)$/i
          return addresses(rule_value)
        else
          return rule_value
        end
      else
        if hash[1] != nil
          if hash[1][rule_value]
            return hash[1][rule_value]
          else
            return rule_value
          end
        else
          return rule_value
        end
      end
    end

    munge_hash = Hash.new()
    munge_hash['ensure'] = [ 'present', nil ]
    munge_hash['description'] = [ '', nil ]
    munge_hash['application_name'] = [ '', nil ]
    munge_hash['service_name'] = [ '', nil ]
    munge_hash['protocol'] = [ 6, { 'ICMPv4'=>1, 'IGMP'=>2, 'TCP'=>6, 'UDP'=>17, 'IPv6'=>41, 'IPv6Route'=>43, 'IPv6Frag'=>44, 'GRE'=>47, 'ICMPv6'=>58, 'IPv6NoNxt'=>59, 'IPv6Opts'=>60, 'VRRP'=>112, 'PGM'=>113, 'L2TP'=>115 } ]
    munge_hash['local_ports'] = [ '*', nil ]
    munge_hash['remote_ports'] = [ '*', nil ]
    munge_hash['local_addresses'] = [ '*', nil ]
    munge_hash['remote_addresses'] = [ '*', nil ]
    munge_hash['icmp_types_and_codes'] = [ '', nil ]
    munge_hash['direction'] = [ 1, { 'In'=>1, 'Out'=>2 } ]
    munge_hash['interfaces'] = [ nil, nil ]
    munge_hash['interface_types'] = [ 'All', nil ]
    munge_hash['enabled'] = [ true, nil ]
    munge_hash['grouping'] = [ '', nil]
    munge_hash['profiles'] = [ 2147483647, { 'Domain'=>1, 'Private'=>2, 'Public'=>4 } ]
    munge_hash['edge_traversal'] = [ false, nil ]
    munge_hash['action'] = [ 1, { 'Allow'=>1, 'Block'=>0 } ]
    munge_hash['edge_traversal_options'] = [ 0, { 'Block'=>0, 'Allow'=>1, 'Defer to App'=>2, 'Defer to User'=>3 } ]

    munge do |value|
      value.each do |name, rule|
        parsed_attr = Hash.new()
        munge_hash.keys.each do |key|
          if rule.has_key?(key)
            parsed_attr[key] = parse_munge_hash(rule[key], munge_hash[key], key)
          else
            if ['local_ports', 'remote_ports'].include?(key)
              parsed_attr[key] = ports(rule['protocol'], munge_hash[key][0] )
            else
              parsed_attr[key] = munge_hash[key][0]
            end
          end
        end
        value[name] = parsed_attr
      end
      value = Digest::MD5.hexdigest Marshal.dump(value.sort.to_s)
    end
  end
end