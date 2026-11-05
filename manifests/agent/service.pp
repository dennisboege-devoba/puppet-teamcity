# @summary Manages the build agent systemd service
#
# @api private
#
class teamcity::agent::service {
  assert_private()

  file { '/etc/systemd/system/build-agent.service':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('teamcity/build-agent.service.epp', {
      'agent_user' => $teamcity::agent_user,
      'agent_dir'  => $teamcity::agent_dir,
    }),
  }

  # leftovers of module versions before 3.0.0
  file { ['/lib/systemd/system/build-agent.service', '/etc/init.d/build-agent']:
    ensure => 'absent',
  }

  service { 'build-agent':
    ensure    => $teamcity::service_ensure,
    enable    => $teamcity::service_enable,
    subscribe => File['/etc/systemd/system/build-agent.service'],
    require   => File['/lib/systemd/system/build-agent.service', '/etc/init.d/build-agent'],
  }
}
