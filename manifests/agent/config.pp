# @summary Configures the build agent
#
# @api private
#
class teamcity::agent::config {
  assert_private()

  $required_properties = {
    'serverUrl' => $teamcity::server_url,
    'name'      => $teamcity::agent_name,
  }

  inifile::create_ini_settings(
    { '' => $required_properties + $teamcity::custom_properties },
    { 'path' => "${teamcity::agent_dir}/conf/buildAgent.properties" }
  )

  inifile::create_ini_settings(
    { '' => $teamcity::launcher_wrapper_conf },
    { 'path' => "${teamcity::agent_dir}/launcher/conf/wrapper.conf" }
  )

  file { '/etc/profile.d/teamcity.sh':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('teamcity/teamcity-profile.sh.epp', { 'mem_opts' => $teamcity::teamcity_agent_mem_opts }),
  }
}
