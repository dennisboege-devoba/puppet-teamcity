# frozen_string_literal: true

require 'spec_helper'

describe 'teamcity build agent' do
  describe file('/opt/build-agent/conf/buildAgent.properties') do
    its(:content) { is_expected.to match(%r{^serverUrl=http://teamcity-server:8111$}) }
  end

  describe service('build-agent') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  # the first start can take a while, the agent unpacks its plugins before it registers
  describe command("timeout 300 sh -c 'until grep -q \"Registered on server with id\" /opt/build-agent/logs/teamcity-agent.log; do sleep 5; done'") do
    its(:exit_status) { is_expected.to eq 0 }
  end
end
