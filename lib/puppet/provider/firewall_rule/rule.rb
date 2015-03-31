require 'win32ole' if Puppet.features.microsoft_windows?

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

class Firewall_Rule
  def initialize(resource)
    @hnet_rule = WIN32OLE.new("HNetCfg.FWRule")
    resource_hash = resource.to_hash
    @property_name_array = Array.new
    @hnet_rule.ole_get_methods.each do |property|
      @property_name_array << property.to_s.downcase
    end

    resource_hash.each_key do |key|
      parsed_key = key.to_s.split('_').join
      if @property_name_array.include?(parsed_key)
        @hnet_rule.setproperty(parsed_key, resource_hash[key])
      end
    end
  end

  def hnet_rule
    return @hnet_rule
  end

  def attributes
    return @property_name_array
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
    system_rules.each do |system_rule|
      if resources.each_key.include?(system_rule.name)
        resources[system_rule.name].provider = system_rule
      end
    end
  end

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  ["local_ports","remote_ports","local_addresses","remote_addresses"].each do |method|
    define_method(method) do
      validate_attribute(:"#{method}")
    end
  end

  ["description","application_name","service_name","protocol","local_ports",
   "remote_ports","local_addresses","remote_addresses","icmp_types_and_codes",
   "direction","interfaces","interface_types","enabled","grouping","profiles",
   "edge_traversal","action","edge_traversal_options"].each do |method|
    define_method(method + "=") do |value|
      @property_flush[:set_attribute] = true
    end
  end

  def create
    @property_flush[:ensure] = :present
  end
  
  def destroy
    @property_flush[:ensure] = :absent
  end
  
  def exists?
    @property_hash [ :ensure ] == :present
  end

  def flush
    system_rules = WIN32OLE.new("HNetCfg.FwPolicy2").rules
    rule_count = rule_count(system_rules)
    if @property_flush[:ensure] == :absent
      remove_rule(rule_count, system_rules, false)
      return
    elsif @property_flush[:ensure] == :present
      system_rules.add(rule_obj.hnet_rule)
      return
    end

    if @property_flush[:set_attribute]
      set_rule(system_rules)
    end

    if rule_count > 1
      system_rules.add(rule_obj)
      remove_rule(rule_count, system_rules, true)
    end
  end

  def validate_attribute(attribute)
    attr_string = attribute.to_s.split('_').join
    if @resource[:ensure] == :absent
      return :absent
    elsif rule_obj.hnet_rule.invoke(attr_string) == @property_hash[attribute]
      return @resource[attribute]
    else
      return @property_hash[attribute]
    end
  end

  def rule_obj
    return @rule_obj if defined?(@rule_obj)
	@rule_obj = Firewall_Rule.new(@resource)
    @rule_obj
  end

  def rule_count(system_rules)
    return system_rules.select('name', @resource[:name]).count
  end

  def remove_rule(rule_count, system_rules, prune)
    if prune then x=1 else x=0 end 
    while rule_count > x do
      system_rules.remove(@resource[:name])
      rule_count = rule_count - 1
    end
  end

  def set_rule(system_rules)
    def set_attr(system_rule, puppet_rule, attr_names) 
      attr_names.each do |attr_name|
        if system_rule.invoke(attr_name) != puppet_rule.invoke(attr_name)
          system_rule.setproperty(attr_name, puppet_rule.invoke(attr_name))
        end
      end
    end
    
    def attr_recovery(system_rules, puppet_rule, system_rule, attr_names, error)
      case error.to_s
      when /.*OLE method `protocol':.*/i
        system_rule.setproperty('IcmpTypesAndCodes',  nil)
        set_attr(system_rule, puppet_rule, attr_names)
      when /.*OLE method `(application|service)name':.*/i
        remove_rule(system_rules, puppet_rule.name, false)
        system_rules.add(puppet_rule)
      else
        raise WIN32OLERuntimeError, error
      end
    end
    
    system_rules.select('name', @resource[:name]).each do |rule|
      begin
        set_attr(rule, rule_obj.hnet_rule, rule_obj.attributes)
      rescue WIN32OLERuntimeError => error
        attr_recovery(system_rules, rule_obj.hnet_rule, rule, rule_obj.attributes, error)
      end
    end
  end
end