$Name = '<%= @attr_name %>'
$Value = '<%= @attr_value %>'
$Key = "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules"
New-ItemProperty -Path Registry::$Key -Name $Name -PropertyType String -Value $Value