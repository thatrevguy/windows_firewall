require 'win32ole'

class Firewall
  @system_rules = WIN32OLE.new("HNetCfg.FwPolicy2").rules

  def self.getrules(rules)
    @system_rules.each do |rule|
      puts rule.name
	end
  end
end

def system_rule_hash(rulename)
  rules = WIN32OLE.new("HNetCfg.FwPolicy2").rules
  rule_hash = Hash.new()

  rules.each do |rule|
    if rule.enabled == true and rule.direction == 1
      if rule.name == rulename or rulename == nil
        attr_hash = Hash.new()
        attr_hash['ensure'] = 'present'
        attr_hash['description'] = rule.description
        attr_hash['application_name'] = rule.applicationname
        attr_hash['service_name'] = rule.servicename
        attr_hash['protocol'] = rule.protocol
        attr_hash['local_ports'] = rule.localports
        attr_hash['remote_ports'] = rule.remoteports
        attr_hash['local_addresses'] = rule.localaddresses
        attr_hash['remote_addresses'] = rule.remoteaddresses
        attr_hash['icmp_types_and_codes'] = rule.icmptypesandcodes
        attr_hash['direction'] = rule.direction
        attr_hash['interfaces'] = rule.interfaces
        attr_hash['interface_types'] = rule.interfacetypes
        attr_hash['enabled'] = rule.enabled
        attr_hash['grouping'] = rule.grouping
        attr_hash['profiles'] = rule.profiles
        attr_hash['edge_traversal'] = rule.edgetraversal
        attr_hash['action'] = rule.action
        attr_hash['edge_traversal_options'] = rule.edgetraversaloptions
        rule_hash[rule.name] = attr_hash
      end
    end
  end

  return rule_hash.sort
end

Puppet::Type.type(:firewall_rule).provide(:rule) do
  desc "Configures rules"

  def create
  end
  
  def destroy
  end
  
  def exists?
    true
  end
  
  def rule_hash
    File.open(File.join('C:\\', 'system_rules.txt'), 'w') {|f| f.write(system_rule_hash(nil)) }
    File.open(File.join('C:\\', 'json_rules.txt', 'w') {|f| f.write(@resource.should(:rule_hash)) }
    @resource.should(:rule_hash)
  end
  
  def rule_hash=(value)
    
  end
end