Puppet::Type.type(:firewall_rule).provide(:rule) do
  desc "Operate on rules for ensurable"

  def apply_rule
    require 'win32ole'
    firewall = WIN32OLE.new("HNetCfg.FwPolicy2")
    firewall.rules.each do |rule|
      puts rule.name
    end
  end
  
  def validate_rule
  
  end
end