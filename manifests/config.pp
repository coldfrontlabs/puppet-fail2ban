# Configure fail2ban service
#
# This class should not be included directly. Users must use the fail2ban
# class.
class fail2ban::config {

  $ignoreip = $fail2ban::ignoreip
  $bantime = $fail2ban::bantime
  $findtime = $fail2ban::findtime
  $maxretry = $fail2ban::maxretry
  $ignorecommand = $fail2ban::ignorecommand
  $backend = $fail2ban::backend
  $destemail = $fail2ban::destemail
  $banaction = $fail2ban::banaction
  $chain = $fail2ban::chain
  $mta = $fail2ban::mta
  $protocol = $fail2ban::protocol
  $action = $fail2ban::action
  $usedns = $fail2ban::usedns
  $persistent_bans = $fail2ban::persistent_bans

  case $::osfamily {
    'Debian': {
      $jail_template_name = "${module_name}/debian/jail.conf.erb"
      $before_include = 'iptables-common.conf'
    }
    'RedHat': { $jail_template_name = "${module_name}/rhel/jail.conf.erb" }
    default: { fail("Unsupported Operating System family: ${::osfamily}") }
  }

  if $fail2ban::purge_jail_dot_d {
    file { '/etc/fail2ban/jail.d':
      ensure  => directory,
      recurse => true,
      purge   => true,
    }
  }
  if $persistent_bans {
    file { '/etc/fail2ban/persistent.bans':
      ensure  => 'present',
      replace => 'no',
      mode    => '0644',
    }
  }
  file { '/etc/fail2ban/action.d/iptables-multiport.conf':
    ensure  => present,
    owner   => 'root',
    group   => 0,
    mode    => '0644',
    content => template('fail2ban/iptables-multiport.erb'),
  }

  file { '/etc/fail2ban/jail.conf':
    ensure  => present,
    owner   => 'root',
    group   => 0,
    mode    => '0644',
    content => template($jail_template_name),
  }

  if $fail2ban::rm_jail_local {
    file { '/etc/fail2ban/jail.local':
      ensure => absent,
    }
  }

}
