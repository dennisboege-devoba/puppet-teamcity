# @summary Installs and configures a TeamCity build agent
#
# @example
#   include teamcity
#
# @param agent_name
#   Build agent name, displayed on the TeamCity server.
# @param agent_user
#   User that runs the build agent.
# @param agent_user_home
#   Home directory of a managed user. Defaults to `agent_dir`.
# @param manage_agent_user_home
#   Whether to create the home directory of a managed user.
# @param agent_group
#   Group of the build agent user.
# @param manage_user
#   Whether to create the build agent user.
# @param manage_group
#   Whether to create the build agent group.
# @param server_url
#   Root URL of the TeamCity server, written to the agent config.
# @param archive_name
#   Name of the agent archive on the server.
# @param download_url
#   URL of the agent archive. Defaults to `${server_url}/update/${archive_name}`.
# @param agent_dir
#   Installation directory of the build agent.
# @param service_ensure
#   State of the build agent service.
# @param service_enable
#   Whether the build agent service starts at boot.
# @param service_provider
#   Deprecated and ignored, the agent always runs as systemd service.
# @param teamcity_agent_mem_opts
#   Java options exported as `TEAMCITY_AGENT_MEM_OPTS`.
# @param custom_properties
#   Settings merged into `conf/buildAgent.properties`.
# @param launcher_wrapper_conf
#   Settings merged into `launcher/conf/wrapper.conf`.
#
class teamcity (
  String[1] $agent_name = $facts['networking']['hostname'],
  String[1] $agent_user = 'teamcity',
  Optional[Stdlib::Absolutepath] $agent_user_home = undef,
  Boolean $manage_agent_user_home = false,
  String[1] $agent_group = 'teamcity',
  Boolean $manage_user = false,
  Boolean $manage_group = false,
  Stdlib::HTTPUrl $server_url = 'http://builder',
  String[1] $archive_name = 'buildAgent.zip',
  Optional[Stdlib::HTTPUrl] $download_url = undef,
  Stdlib::Absolutepath $agent_dir = '/opt/build-agent',
  Stdlib::Ensure::Service $service_ensure = 'running',
  Boolean $service_enable = true,
  Optional[String] $service_provider = undef,
  String $teamcity_agent_mem_opts = '-Xms512m -Xmx1024m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8',
  Hash $custom_properties = {},
  Hash $launcher_wrapper_conf = {},
) {
  if $service_provider {
    warning('teamcity::service_provider is deprecated and ignored, the agent always runs as systemd service')
  }

  contain teamcity::account
  contain teamcity::agent::install
  contain teamcity::agent::config
  contain teamcity::agent::service

  Class['teamcity::account']
  -> Class['teamcity::agent::install']
  -> Class['teamcity::agent::config']
  ~> Class['teamcity::agent::service']
}
