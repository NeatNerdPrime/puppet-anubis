# frozen_string_literal: true

require 'spec_helper'

describe 'anubis' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_package('anubis') }

      context 'on RedHat family' do
        next unless os_facts[:os]['family'] == 'RedHat'

        let(:facts) { os_facts.merge({ 'os' => os_facts[:os].merge({ 'architecture' => 'x86_64' }) }) }

        it 'uses RPM package URL as source' do
          is_expected.to contain_package('anubis').with_source(
            %r{releases/download/v1\.23\.1/anubis-1\.23\.1-1\.x86_64\.rpm}
          )
        end

        it 'uses no explicit provider' do
          is_expected.to contain_package('anubis').with_provider(nil)
        end

        it 'ensures present' do
          is_expected.to contain_package('anubis').with_ensure('present')
        end

        it 'does not manage an archive resource' do
          is_expected.not_to contain_archive('/tmp/anubis-1.23.1-1.x86_64.rpm')
        end
      end

      context 'on Debian family' do
        next unless os_facts[:os]['family'] == 'Debian'

        context 'with x86_64 architecture' do
          let(:facts) { os_facts.merge({ 'os' => os_facts[:os].merge({ 'architecture' => 'x86_64' }) }) }

          it 'downloads the amd64 deb via archive' do
            is_expected.to contain_archive('/tmp/anubis_1.23.1_amd64.deb').with(
              ensure: 'present',
              source: %r{releases/download/v1\.23\.1/anubis_1\.23\.1_amd64\.deb}
            )
          end

          it 'installs from the staged local file' do
            is_expected.to contain_package('anubis').with_source('/tmp/anubis_1.23.1_amd64.deb')
          end

          it 'uses dpkg provider' do
            is_expected.to contain_package('anubis').with_provider('dpkg')
          end

          it 'ensures present' do
            is_expected.to contain_package('anubis').with_ensure('present')
          end

          it 'orders archive before package' do
            is_expected.to contain_archive('/tmp/anubis_1.23.1_amd64.deb').that_comes_before('Package[anubis]')
          end
        end

        context 'with aarch64 architecture' do
          let(:facts) { os_facts.merge({ 'os' => os_facts[:os].merge({ 'architecture' => 'aarch64' }) }) }

          it 'downloads the arm64 deb via archive' do
            is_expected.to contain_archive('/tmp/anubis_1.23.1_arm64.deb').with(
              source: %r{releases/download/v1\.23\.1/anubis_1\.23\.1_arm64\.deb}
            )
          end

          it 'installs from the staged arm64 file' do
            is_expected.to contain_package('anubis').with_source('/tmp/anubis_1.23.1_arm64.deb')
          end
        end

        context 'with non-standard architecture' do
          let(:facts) { os_facts.merge({ 'os' => os_facts[:os].merge({ 'architecture' => 'armv7l' }) }) }

          it 'uses architecture as-is in URL and staging path' do
            is_expected.to contain_archive('/tmp/anubis_1.23.1_armv7l.deb').with(
              source: %r{releases/download/v1\.23\.1/anubis_1\.23\.1_armv7l\.deb}
            )
          end

          it 'installs from the staged file with original arch name' do
            is_expected.to contain_package('anubis').with_source('/tmp/anubis_1.23.1_armv7l.deb')
          end
        end

        context 'with custom staging_dir' do
          let(:facts) { os_facts.merge({ 'os' => os_facts[:os].merge({ 'architecture' => 'x86_64' }) }) }
          let(:params) { { 'staging_dir' => '/opt/staging' } }

          it 'stages the deb under the custom dir' do
            is_expected.to contain_archive('/opt/staging/anubis_1.23.1_amd64.deb')
          end

          it 'installs from the custom staging path' do
            is_expected.to contain_package('anubis').with_source('/opt/staging/anubis_1.23.1_amd64.deb')
          end
        end
      end
    end
  end

  context 'with custom package_version' do
    let(:facts) { on_supported_os.first[1] }
    let(:params) { { 'package_version' => '2.0.0' } }

    it { is_expected.to compile.with_all_deps }
    it 'uses the custom version in the URL' do
      is_expected.to contain_package('anubis').with_source(%r{v2\.0\.0})
    end
  end

  context 'with custom package_name' do
    let(:facts) { on_supported_os.first[1] }
    let(:params) { { 'package_name' => 'anubis-custom' } }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_package('anubis-custom') }
  end

  context 'on unsupported OS family' do
    let(:facts) do
      on_supported_os.first[1].merge(
        {
          'os' => on_supported_os.first[1][:os].merge({ 'family' => 'Windows' })
        }
      )
    end

    it { is_expected.to compile.and_raise_error(%r{unsupported OS family}) }
  end
end
