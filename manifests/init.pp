# @summary Install and configure Anubis
#
# @param package_version
#   The version to install
class anubis (
  String[1] $package_version = '1.23.1'
) {
  case $facts['os']['family'] {
    'RedHat': {
      $package_url     = "https://github.com/TecharoHQ/anubis/releases/download/v${package_version}/anubis-${package_version}-1.${facts['os']['architecture']}.rpm"
      $package_ensure  = $package_version
      $package_provider = undef
    }
    'Debian': {
      $deb_arch = $facts['os']['architecture'] ? {
        'x86_64'  => 'amd64',
        'aarch64' => 'arm64',
        default   => $facts['os']['architecture'],
      }
      $package_url      = "https://github.com/TecharoHQ/anubis/releases/download/v${package_version}/anubis_${package_version}_${deb_arch}.deb"
      # dpkg provider does not support versionable; version is encoded in the source URL
      $package_ensure   = 'present'
      $package_provider = 'dpkg'
    }
    default: {
      fail("puppet-anubis: unsupported OS family '${facts['os']['family']}'")
    }
  }

  package { 'anubis':
    ensure   => $package_ensure,
    source   => $package_url,
    provider => $package_provider,
  }
}
