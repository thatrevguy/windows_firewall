Puppet::Type.type(:firewall_rule).provide(:rule) do
  desc "Operate on rules for ensurable"
  
  def create
    #File.open(@resource[:name], "w") { |f| f.puts "" } # Create an empty file
  end
  
  def destroy
    #File.unlink(@resource[:name])
  end
  
  def exists?
    #File.exists?(@resource[:name])
  end
end