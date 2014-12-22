Facter.add(:firewall_rules) do
  confine :operatingsystem => 'windows'
  setcode do

    require 'win32ole'

    class WIN32OLE
      def select(attr_name, value)
        selected = Array.new()
        self.each do |x|
          x_value = x.invoke(attr_name)
          if x_value =~ /^#{value}$/i or x_value == value
            selected.push(x)
          end
        end
    
        return selected
      end
    end

    system_rules = WIN32OLE.new("HNetCfg.FwPolicy2").rules
    rule_array = Array.new()
    attr_names = Hash.new()
    attr_names['name'] = 'name'
    attr_names['protocol'] = 'protocol'
    attr_names['localports'] = 'local_ports'
    attr_names['remoteports'] = 'remote_ports'
    attr_names['localaddresses'] = 'local_addresses'
    attr_names['remoteaddresses'] = 'remote_addresses'
    attr_names['direction'] = 'direction'
    attr_names['action'] = 'action'

    system_rules.select('enabled', true).each do |rule|
      attr_hash = Hash.new()
      attr_names.keys.each do |key|
        attr_value = rule.invoke(key)
        if attr_value != ''
          attr_hash[attr_names[key]] = attr_value
        end
      end
      rule_array.push(attr_hash)
    end

    rule_array.to_json.to_s
  end
end