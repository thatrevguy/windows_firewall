$Name = '<%= @attr_name %>'
$Key = "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules"
if(!(Get-ItemProperty -Path Registry::$Key -Name $Name -ErrorAction SilentlyContinue)){ exit 1 }