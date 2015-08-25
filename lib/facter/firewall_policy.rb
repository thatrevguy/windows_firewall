cmd = "c:\\Windows\\System32\\netsh.exe advfirewall show allprofiles firewallpolicy | findstr \"Policy\""

Facter.add('in_policy_fact') do
  confine :operatingsystem => 'windows'
  setcode do
    state = Facter::Util::Resolution.exec(cmd).chomp
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
    state = Facter::Util::Resolution.exec(cmd).chomp
    if state.match('AllowOutbound')
      'AllowOutbound'
    else
      'BlockOutbound'
    end
  end
end
