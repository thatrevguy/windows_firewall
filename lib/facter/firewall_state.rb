Facter.add('profile_state_fact') do
  confine :operatingsystem => 'windows'
  setcode do
    cmd = "c:\\Windows\\System32\\netsh.exe advfirewall show allprofiles state | findstr \"State\" "
    #This comes back as a long string of text, but let's generalize
    state = Facter::Util::Resolution.exec(cmd).chomp

    if state.match('OFF')
      'off'
    else
      'on'
    end
  end
end