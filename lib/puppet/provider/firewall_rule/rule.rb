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

def generate_rules(rule_hash)
  rule_array = Array.new()
  rule_hash.each do |name, rule|
    if rule['ensure'] == 'present'
      rule_attr = Hash.new()
      rule_attr['name'] = name
      rule.keys.each do |key|
        if key != 'ensure'
          rule_attr[key.split('_').join] = rule[key]
        end
      end

      hnet_rule = WIN32OLE.new("HNetCfg.FWRule")
      rule_attr.keys.each do |key|
        if rule_attr[key]
          message = "Rule \'%s\' %s attribute value of \'%s\' is invalid." % [name, key, rule_attr[key].to_s]
          hnet_rule.setproperty(key, rule_attr[key]) rescue raise ArgumentError, message
        end
      end

      rule_array.push(hnet_rule)
    end
  end

  return rule_array
end

def validate_rule(system_rules, puppet_rule, attr_names)
    system_rules.select('name', puppet_rule.name).each do |rule|
      attr_names.each do |attr_name|
        if rule.invoke(attr_name.to_s) != puppet_rule.invoke(attr_name.to_s)
          return false
        end
      end
    end

  return true
end

def set_rule(system_rules, puppet_rule, attr_names)
  def set_attr(sys_rule, puppet_rule, attr_names) 
    attr_names.each do |attr_name|
      if sys_rule.invoke(attr_name.to_s) != puppet_rule.invoke(attr_name.to_s)
        sys_rule.setproperty(attr_name.to_s, puppet_rule.invoke(attr_name.to_s))
      end
    end
  end

  def attr_recovery(system_rule, error)
    case error.to_s
    when /.*OLE method `protocol':.*/i
      system_rule.setproperty('IcmpTypesAndCodes',  nil)
    else
      raise WIN32OLERuntimeError, error
    end
  end

  system_rules.select('name', puppet_rule.name).each do |rule|
    begin
      set_attr(rule, puppet_rule, attr_names)
    rescue WIN32OLERuntimeError => error
      attr_recovery(rule, error)
      set_attr(rule, puppet_rule, attr_names)
    end
  end
end

def prune_rule(system_rules, name, count)
  while count > 1 do
    system_rules.remove(name)
    count = count - 1
  end
end

def ensure_rules(rule_hash, check_flag)
  system_rules = WIN32OLE.new("HNetCfg.FwPolicy2").rules
  puppet_rules = generate_rules(rule_hash)

  def present_rules(system_rules, puppet_rules, check_flag)
    attr_names = WIN32OLE.new("HNetCfg.FWRule").ole_get_methods
    puppet_rules.each do |puppet_rule|
      rule_count = system_rules.select('name', puppet_rule.name).count
      if rule_count > 0
        if !validate_rule(system_rules, puppet_rule, attr_names)
          #return false if check_flag
		  return puppet_rule.name if check_flag
          set_rule(system_rules, puppet_rule, attr_names)
        end
      else
        #return false if check_flag
		return puppet_rule.name if check_flag
        system_rules.add(puppet_rule)
      end

      if rule_count > 1
        #return false if check_flag
		return puppet_rule.name if check_flag
        prune_rule(system_rules, puppet_rule.name, rule_count)
      end
    end
  end

  def absent_rules(system_rules, rule_hash, check_flag)
    rule_hash.each do |name, rule|
      if rule['ensure'] == 'absent'
        rule_count = system_rules.select('name', name).count
        while rule_count > 0 do
          #return false if check_flag
		  return name if check_flag
          system_rules.remove(name)
          rule_count = rule_count - 1
        end
      end
    end
  end

  def disable_rules(system_rules, puppet_rules, check_flag)
    system_rule_array = Array.new()
    hash_rule_array = Array.new()
    system_rules.each do |rule| system_rule_array.push(rule.name) end
    puppet_rules.each do |rule| hash_rule_array.push(rule.name) end

    (system_rule_array - hash_rule_array).sort.uniq.each do |name|
      system_rules.select('name', name).each do |rule|
        if rule.enabled
          #return false if check_flag
		  return rule.name if check_flag
          rule.setproperty('enabled', false)
        end
      end
    end
  end
  
  
  #return false if !present_rules(system_rules, puppet_rules, check_flag)
  #return false if !absent_rules(system_rules, rule_hash, check_flag)
  #return false if !disable_rules(system_rules, puppet_rules, check_flag)

  return present_rules(system_rules, puppet_rules, check_flag)
  #return absent_rules(system_rules, rule_hash, check_flag)
  #return disable_rules(system_rules, puppet_rules, check_flag)
end

Puppet::Type.type(:firewall_rule).provide(:rule) do
  desc "Configures rules"

  def rule_hash
    #File.open(File.join('C:\\', 'system_rules.txt'), 'w') {|f| f.write(system_rule_hash(nil)) }
    #File.open(File.join('C:\\', 'json_rules.txt'), 'w') {|f| f.write(@resource.should(:rule_hash)) }
    #@resource.should(:rule_hash)
    #if !ensure_rules(@resource.should(:rule_hash), true)
    #  return "mismatch found"
    #else
	  puts ensure_rules(@resource.should(:rule_hash), true)
      return @resource.should(:rule_hash)
    #end
  end
  
  def rule_hash=(value)
    ensure_rules(@resource.should(:rule_hash), false)
  end
end