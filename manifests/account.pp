# @summary Manages the build agent user and group
#
# @api private
#
class teamcity::account {
  assert_private()

  if $teamcity::manage_group and !defined(Group[$teamcity::agent_group]) {
    group { $teamcity::agent_group:
      ensure => 'present',
    }
  }

  if $teamcity::manage_user and !defined(User[$teamcity::agent_user]) {
    user { $teamcity::agent_user:
      ensure     => 'present',
      home       => pick($teamcity::agent_user_home, $teamcity::agent_dir),
      managehome => $teamcity::manage_agent_user_home,
      gid        => $teamcity::agent_group,
      shell      => '/bin/sh',
    }
  }
}
