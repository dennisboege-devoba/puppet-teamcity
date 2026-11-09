# teamcity

Installs and configures a [TeamCity](https://www.jetbrains.com/teamcity) build agent
and runs it as systemd service.

The agent archive is downloaded from the TeamCity server, unpacked to `agent_dir`
and configured through `conf/buildAgent.properties` and `launcher/conf/wrapper.conf`.

## Usage

```puppet
include teamcity
```

```puppet
class { 'teamcity':
  agent_name            => 'sample-build-agent',
  server_url            => 'https://teamcity.example.com',
  manage_user           => true,
  manage_group          => true,
  custom_properties     => {
    'system.teamcity.idea.home' => '%system.agent.home.dir%/tools/idea',
  },
  launcher_wrapper_conf => {
    'wrapper.app.parameter.11' => '-Dfile.encoding=UTF-8',
  },
}
```

```yaml
teamcity::agent_name: sample-build-agent
teamcity::agent_dir: /var/tainted/build-agent
teamcity::custom_properties:
  "system.teamcity.idea.home": "%system.agent.home.dir%/tools/idea"
```

All parameters are documented in [REFERENCE.md](REFERENCE.md).

## Upgrading to 3.0.0

- The agent always runs as systemd service `build-agent` with its unit in
  `/etc/systemd/system`. Old units in `/lib/systemd/system` and init scripts in
  `/etc/init.d` are removed, the service restarts once.
- `service_provider` is ignored and only logs a deprecation warning.
- Parameters are typed, `server_url` and `download_url` must be HTTP(S) URLs and
  boolean parameters must be real booleans.
- `maestrodev-wget` is replaced by `puppet/archive`, `unzip` gets installed.

## Development

```sh
bundle install
bundle exec rake test rubocop
bundle exec rake strings:generate:reference
```

The integration tests install the agent with test-kitchen in systemd containers
and check that it registers with a TeamCity server:

```sh
docker network create kitchen
docker run -d --name teamcity-server --network kitchen \
  -e TEAMCITY_SERVER_OPTS="-Dteamcity.startup.maintenance=false -Dteamcity.licenseAgreement.accepted=true" \
  jetbrains/teamcity-server:2026.2.2
bundle exec kitchen test
```

Agents of TeamCity 2026.2 need Java 21, which this module does not install.
