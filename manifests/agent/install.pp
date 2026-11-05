# PRIVATE CLASS: do not call directly
class teamcity::agent::install {
  require teamcity::account

  if $::teamcity::download_url {
    $download_url = $::teamcity::download_url
  }
  else {
    $download_url = "${::teamcity::server_url}/update/${::teamcity::archive_name}"
  }

  # ruby provider ignores http_proxy, download stays direct
  archive { 'teamcity-buildagent':
    path    => "${::temp_dir}/${::teamcity::archive_name}",
    source  => $download_url,
    extract => false,
    cleanup => false,
  }

  exec { 'extract-agent-archive':
    command   => "unzip ${::temp_dir}/${::teamcity::archive_name} -d ${::teamcity::agent_dir}",
    creates   => "${::teamcity::agent_dir}/conf",
    logoutput => 'on_failure',
    require   => Archive['teamcity-buildagent'],
  }

  file {'agent-config':
    ensure  => 'file',
    path    => "${::teamcity::agent_dir}/conf/buildAgent.properties",
    replace => 'no',
    source  => "${::teamcity::agent_dir}/conf/buildAgent.dist.properties",
    group   => $::teamcity::agent_group,
    owner   => $::teamcity::agent_user,
    require => Exec['extract-agent-archive'],
  }

  exec { 'chown-agent-dir':
    command     => "chown -R ${::teamcity::agent_user}:${::teamcity::agent_group} ${::teamcity::agent_dir}",
    subscribe   => Exec['extract-agent-archive'],
    refreshonly => true,
    logoutput   => 'on_failure',
    require     => Exec['extract-agent-archive'],
  }

  file { "${::teamcity::agent_dir}/bin/agent.sh":
    mode    => '0755',
    require => Exec['extract-agent-archive'],
  }
}
