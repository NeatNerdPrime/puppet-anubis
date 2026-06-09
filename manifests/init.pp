# @summary Install and configure Anubis
#
# @param package_name
#   The package name to install
#
# @param package_version
#   The version to install (used to construct the download URL)
#
# @param package_ensure
#   The ensure value for the package resource
#
# @param package_provider
#   The Puppet package provider to use (e.g. 'dpkg' on Debian, undef for RPM default)
#
# @param staging_dir
#   Local directory to stage downloaded packages before installation (Debian only)
class anubis (
  String[1]            $package_name     = 'anubis',
  String[1]            $package_version  = '1.23.1',
  String[1]            $package_ensure   = 'present',
  Optional[String[1]]  $package_provider = undef,
  Stdlib::Absolutepath $staging_dir      = '/tmp',
) {
  case $facts['os']['family'] {
    'RedHat': {
      $package_source = "https://github.com/TecharoHQ/anubis/releases/download/v${package_version}/anubis-${package_version}-1.${facts['os']['architecture']}.rpm"
    }
    'Debian': {
      $deb_arch = $facts['os']['architecture'] ? {
        'x86_64'  => 'amd64',
        'aarch64' => 'arm64',
        default   => $facts['os']['architecture'],
      }
      $package_source = "${staging_dir}/anubis_${package_version}_${deb_arch}.deb"

      # dpkg provider requires a local file; use puppet/archive to download first
      archive { $package_source:
        ensure => present,
        source => "https://github.com/TecharoHQ/anubis/releases/download/v${package_version}/anubis_${package_version}_${deb_arch}.deb",
        before => Package[$package_name],
      }
    }
    default: {
      fail("puppet-anubis: unsupported OS family '${facts['os']['family']}'")
    }
  }

  package { $package_name:
    ensure   => $package_ensure,
    source   => $package_source,
    provider => $package_provider,
  }
}
