require 'win32ole'

class Firewall_Rule
  def initialize(resource)
    @hnet_rule = WIN32OLE.new("HNetCfg.FWRule")
    resource_hash = resource.to_hash
    property_name_array = Array.new
    @hnet_rule.ole_get_methods.each do |property|
      property_name_array << property.to_s.downcase
    end

    resource_hash.each_key do |key|
      parsed_key = key.to_s.split('_').join
      if property_name_array.include?(parsed_key)
        @hnet_rule.setproperty(parsed_key, resource_hash[key])
      end
    end
  end

  def hnet_rule
    return @hnet_rule
  end
end

Puppet::Type.type(:firewall_rule).provide(:rule) do
  desc "Configures rule"

  mk_resource_methods

  def self.instances
    system_rules = WIN32OLE.new("HNetCfg.FwPolicy2").rules
    system_rules.each.collect do |system_rule|
      new( :name => system_rule.invoke('name'),
           :ensure => :present,
           :description => system_rule.invoke('description'),
           :application_name => system_rule.invoke('applicationname'),
           :service_name => system_rule.invoke('servicename'),
           :protocol => system_rule.invoke('protocol'),
           :local_ports => system_rule.invoke('localports'),
           :remote_ports => system_rule.invoke('remoteports'),
           :local_addresses => system_rule.invoke('localaddresses'),
           :remote_addresses => system_rule.invoke('remoteaddresses'),
           :icmp_types_and_codes => system_rule.invoke('icmptypesandcodes'),
           :direction => system_rule.invoke('direction'),
           :interfaces => system_rule.invoke('interfaces'),
           :interface_types => system_rule.invoke('interfacetypes'),
           :enabled => system_rule.invoke('enabled'),
           :grouping => system_rule.invoke('grouping'),
           :profiles => system_rule.invoke('profiles'),
           :edge_traversal => system_rule.invoke('edgetraversal'),
           :action =>system_rule.invoke('action'),
           :edge_traversal_options => system_rule.invoke('edgetraversaloptions')
      )
    end
  end

  def self.prefetch(resources)
    system_rules = instances
    resources.each do |name, resource|
      if provider = system_rules.find{ |item| item.name == name }
        resource.provider = provider
      end
    end
  end

  def local_ports
    if rule_obj.invoke('localports') == @property_hash[:local_ports]
      return @resource[:local_ports]
    else
      return @property_hash[:local_ports]
    end
  end

  def remote_ports
    if rule_obj.invoke('remoteports') == @property_hash[:remote_ports]
      return @resource[:remote_ports]
    else
      return @property_hash[:remote_ports]
    end
  end

  def local_addresses
    if rule_obj.invoke('localaddresses') == @property_hash[:local_addresses]
      return @resource[:local_addresses]
    else
      return @property_hash[:local_addresses]
    end
  end

  def remote_addresses
    if rule_obj.invoke('remoteaddresses') == @property_hash[:remote_addresses]
      return @resource[:remote_addresses]
    else
      return @property_hash[:remote_addresses]
    end
  end

  def create

  end
  
  def delete

  end
  
  def exists?
    @property_hash [ :ensure ] == :present
  end

  private

  def rule_obj
    return @rule_obj if defined?(@rule_obj)
	@rule_obj = Firewall_Rule.new(@resource).hnet_rule
    @rule_obj
  end
end