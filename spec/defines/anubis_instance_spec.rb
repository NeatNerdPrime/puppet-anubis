# frozen_string_literal: true

require 'spec_helper'

describe 'anubis::instance' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'test' }
      let(:params) do
        {
          'target' => 'http://localhost:1234',
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_service('anubis@test') }
      it { is_expected.to contain_file('/etc/anubis/test.env').with_content(%r{^TARGET=http://localhost:1234}) }

      context 'with settings hash' do
        let(:params) do
          {
            'target'   => 'http://localhost:1234',
            'settings' => { 'BIND' => '0.0.0.0', 'PORT' => '8080' },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/etc/anubis/test.env').with_content(%r{^BIND=0\.0\.0\.0}) }
        it { is_expected.to contain_file('/etc/anubis/test.env').with_content(%r{^PORT=8080}) }
      end

      context 'with bot_policies set' do
        let(:params) do
          {
            'target'       => 'http://localhost:1234',
            'bot_policies' => "allow:\n  - '*'\n",
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/etc/anubis/test.botPolicies.yaml') }
        it { is_expected.to contain_file('/etc/anubis/test.env').with_content(%r{^POLICY_FNAME=/etc/anubis/test\.botPolicies\.yaml}) }
      end

      context 'with ensure: absent' do
        let(:params) do
          {
            'target' => 'http://localhost:1234',
            'ensure' => 'absent',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('anubis@test').with_ensure(false) }
        it { is_expected.to contain_service('anubis@test').with_enable(false) }
        it { is_expected.to contain_file('/etc/anubis/test.env').with_ensure('absent') }
      end
    end
  end
end
