$Name = '<%= @attr_name %>'
$Value = '<%= @attr_value %>'
$Key = "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules"
if((Get-ItemProperty -Path Registry::$Key -Name $Name).$Name -ne $Value){ exit 1 }