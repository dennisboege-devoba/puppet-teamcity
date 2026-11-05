# frozen_string_literal: true

require 'spec_helper'

describe 'teamcity' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_package('unzip') }
        it { is_expected.to contain_file('/opt/build-agent').with_ensure('directory') }

        it do
          is_expected.to contain_archive('teamcity-buildagent').with(
            path: '/tmp/buildAgent.zip',
            source: 'http://builder/update/buildAgent.zip',
            extract: true,
            extract_path: '/opt/build-agent',
            creates: '/opt/build-agent/conf',
            cleanup: true,
          ).that_requires(['File[/opt/build-agent]', 'Package[unzip]'])
        end

        it do
          is_expected.to contain_file('agent-config').with(
            path: '/opt/build-agent/conf/buildAgent.properties',
            replace: false,
            owner: 'teamcity',
            group: 'teamcity',
          ).that_requires('Archive[teamcity-buildagent]')
        end

        it do
          is_expected.to contain_exec('chown-agent-dir')
            .with_command('chown -R teamcity:teamcity /opt/build-agent')
            .that_subscribes_to('Archive[teamcity-buildagent]')
        end

        it { is_expected.to contain_ini_setting('/opt/build-agent/conf/buildAgent.properties [] serverUrl').with_value('http://builder') }
        it { is_expected.to contain_ini_setting('/opt/build-agent/conf/buildAgent.properties [] name').with_value(os_facts[:networking]['hostname']) }

        it do
          is_expected.to contain_file('/etc/profile.d/teamcity.sh')
            .with_mode('0644')
            .with_content(%r{^export TEAMCITY_AGENT_MEM_OPTS="-Xms512m })
        end

        it do
          is_expected.to contain_file('/etc/systemd/system/build-agent.service')
            .with_mode('0644')
            .with_content(%r{^User=teamcity$})
            .with_content(%r{^ExecStart=/opt/build-agent/bin/agent\.sh start$})
        end

        it { is_expected.to contain_file('/lib/systemd/system/build-agent.service').with_ensure('absent') }
        it { is_expected.to contain_file('/etc/init.d/build-agent').with_ensure('absent') }

        it do
          is_expected.to contain_service('build-agent').with(
            ensure: 'running',
            enable: true,
          ).that_subscribes_to('File[/etc/systemd/system/build-agent.service]')
        end

        it { is_expected.to contain_class('teamcity::agent::config').that_notifies('Class[teamcity::agent::service]') }
        it { is_expected.not_to contain_user('teamcity') }
        it { is_expected.not_to contain_group('teamcity') }
      end

      context 'with managed account and custom settings' do
        let(:params) do
          {
            manage_user: true,
            manage_group: true,
            agent_dir: '/srv/agent',
            download_url: 'https://tc.example.com/agent.zip',
            custom_properties: { 'env.FOO' => 'bar' },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_group('teamcity') }
        it { is_expected.to contain_user('teamcity').with(home: '/srv/agent', gid: 'teamcity') }
        it { is_expected.to contain_archive('teamcity-buildagent').with_source('https://tc.example.com/agent.zip') }
        it { is_expected.to contain_ini_setting('/srv/agent/conf/buildAgent.properties [] env.FOO').with_value('bar') }
        it { is_expected.to contain_file('/etc/systemd/system/build-agent.service').with_content(%r{^PIDFile=/srv/agent/logs/buildAgent\.pid$}) }
      end

      context 'with deprecated service_provider' do
        let(:params) { { service_provider: 'init' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('build-agent') }
      end
    end
  end
end
