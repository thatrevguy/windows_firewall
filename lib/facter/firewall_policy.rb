cmd = "c:\\Windows\\System32\\netsh.exe advfirewall show allprofiles firewallpolicy | findstr \"Policy\""
state = Facter::Util::Resolution.exec(cmd).chomp

Facter.add('in_policy_fact') do
  confine :operatingsystem => 'windows'
  setcode do
    if state.match('AllowInbound')
      'AllowInbound'
    else
      'BlockInbound'
    end
  end
end

Facter.add('out_policy_fact') do
  confine :operatingsystem => 'windows'
  setcode do
    if state.match('AllowOutbound')
      'AllowOutbound'
    else
      'BlockOutbound'
    end
  end
end