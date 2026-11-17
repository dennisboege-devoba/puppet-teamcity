# @summary Manages the build agent systemd service
#
# @api private
#
class teamcity::agent::service {
  assert_private()

  # leftovers of module versions before 3.0.0
  file { ['/lib/systemd/system/build-agent.service', '/etc/init.d/build-agent']:
    ensure => 'absent',
  }

  $_active = $teamcity::service_ensure ? {
    'running' => true,
    'stopped' => false,
    default   => undef,
  }

  systemd::unit_file { 'build-agent.service':
    ensure  => 'present',
    content => epp('teamcity/build-agent.service.epp', {
        'agent_user' => $teamcity::agent_user,
        'agent_dir'  => $teamcity::agent_dir,
    }),
    active  => $_active,
    enable  => $teamcity::service_enable,
    require => File['/lib/systemd/system/build-agent.service', '/etc/init.d/build-agent'],
  }
}
