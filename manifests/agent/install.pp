# @summary Downloads and unpacks the build agent
#
# @api private
#
class teamcity::agent::install {
  assert_private()

  $download_url = pick($teamcity::download_url, "${teamcity::server_url}/update/${teamcity::archive_name}")

  stdlib::ensure_packages(['unzip'])

  # ruby provider ignores http_proxy, download stays direct
  archive { 'teamcity-buildagent':
    path         => "${facts['temp_dir']}/${teamcity::archive_name}",
    source       => $download_url,
    extract      => true,
    extract_path => $teamcity::agent_dir,
    creates      => "${teamcity::agent_dir}/conf",
    cleanup      => true,
    require      => [File[$teamcity::agent_dir], Package['unzip']],
  }

  file { $teamcity::agent_dir:
    ensure => 'directory',
  }

  file { 'agent-config':
    ensure  => 'file',
    path    => "${teamcity::agent_dir}/conf/buildAgent.properties",
    replace => false,
    source  => "${teamcity::agent_dir}/conf/buildAgent.dist.properties",
    owner   => $teamcity::agent_user,
    group   => $teamcity::agent_group,
    require => Archive['teamcity-buildagent'],
  }

  exec { 'chown-agent-dir':
    command     => "chown -R ${teamcity::agent_user}:${teamcity::agent_group} ${teamcity::agent_dir}",
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
    subscribe   => Archive['teamcity-buildagent'],
  }

  file { "${teamcity::agent_dir}/bin/agent.sh":
    mode    => '0755',
    require => Archive['teamcity-buildagent'],
  }
}
