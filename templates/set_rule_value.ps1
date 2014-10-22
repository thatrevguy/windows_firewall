$Name = '<%= @attr_name %>'
$Value = '<%= @attr_value %>'
$Key = "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules"
Set-ItemProperty -Path Registry::$Key -Name $Name -Value $Value