$Name = '<%= @attr_name %>'
$Key = "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules"
Remove-ItemProperty -Path Registry::$Key -Name $Name