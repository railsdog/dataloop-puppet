# ::dataloop_agent::repo - configure dataloop agent repositories
class dataloop_agent::repo(
  $gpg_key_url = 'https://download.dataloop.io/pubkey.gpg',
  $release = 'stable',
  ) {

  case $::operatingsystem {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'SL', 'SLC', 'Ascendos',
    'CloudLinux', 'PSBM', 'OracleLinux', 'OVS', 'OEL', 'Amazon', 'XenServer': {

      yumrepo { 'dataloop':
        baseurl  => "https://download.dataloop.io/packages/${release}/rpm/${::architecture}",
        descr    => 'Dataloop Repository',
        enabled  => 1,
        gpgkey   => $gpg_key_url,
        gpgcheck => 1,
      }

      exec { 'clean_yum_metadata':
        command     => '/usr/bin/yum clean metadata',
        refreshonly => true,
        require     => Yumrepo['dataloop'],
      }

    }
    'Debian', 'Ubuntu': {
      include apt

      # Avoid apt::key due to breaking changes between 1.x.x and 2.x.x
      # 'apt-key add -' is an indempotent command
      exec { 'add_dataloop_apt_key':
        command => "/usr/bin/wget -q ${gpg_key_url} -O - | /usr/bin/apt-key add -",
        unless  => '/usr/bin/apt-key list | /bin/grep -c dataloop',
      }

      apt::source { 'dataloop':
        location => 'https://download.dataloop.io/deb',
        release  => $release,
        repos    => 'main',
        require  => Exec['add_dataloop_apt_key'],
      }
    }
    default: {
      warning("Module ${module_name} is not supported on ${::lsbdistid}")
    }
  }

}
