class { 'teamcity':
  server_url   => 'http://teamcity-server:8111',
  manage_user  => true,
  manage_group => true,
}
