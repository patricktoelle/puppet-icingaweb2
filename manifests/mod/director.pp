# == Class icingaweb2::mod::director
#
class icingaweb2::mod::director (
  $git_repo             = 'https://github.com/Icinga/icingaweb2-module-director.git',
  $git_revision         = undef,
  $install_method       = 'git',
  $pkg_deps             = undef,
  $pkg_ensure           = 'present',
  $web_root             = $::icingaweb2::params::web_root,
) {
  require ::icingaweb2

  validate_absolute_path($web_root)
  validate_re($install_method,
    [
      'git',
    ]
  )

  File {
    require => Class['::icingaweb2::config'],
    owner => $::icingaweb2::config_user,
    group => $::icingaweb2::config_group,
    mode  => $::icingaweb2::config_file_mode,
  }

  file {
    "${web_root}/modules/director":
      ensure => directory,
      mode   => $::icingaweb2::config_dir_mode;

    "${::icingaweb2::config_dir}/enabledModules/director":
      ensure => 'symlink',
      target => "${::icingaweb2::web_root}/modules/director";

    "${::icingaweb2::config_dir}/modules/director":
      ensure => directory,
      mode   => $::icingaweb2::config_dir_mode;
  }

  ini_setting { 'director database':
    ensure  => present,
    require => File["${::icingaweb2::config_dir}/modules/director"],
    path    => "${::icingaweb2::config_dir}/modules/director/config.ini",
    section => 'db',
    setting => 'resource',
    value   => 'Director DB',
  }

  Ini_Setting {
    ensure  => present,
    require => File["${::icingaweb2::config_dir}/resources.ini"],
    path    => "${::icingaweb2::config_dir}/resources.ini",
    section => 'Director DB',
  }

  ini_setting { 'director database ressource type':
    setting => 'type',
    value   => 'db',
  }
  ini_setting { 'director database ressource db':
    setting => 'db',
    value   => $::icingaweb2::ido_db,
  }
  ini_setting { 'director database ressource host':
    setting => 'host',
    value   => $::icingaweb2::ido_db_host,
  }
  ini_setting { 'director database ressource dbname':
    setting => 'dbname',
    value   => 'icingaweb2_director',
  }
  ini_setting { 'director database ressource username':
    setting => 'username',
    value   => $::icingaweb2::ido_db_user,
  }
  ini_setting { 'director database ressource password':
    setting => 'password',
    value   => $::icingaweb2::ido_db_pass,
  }
  ini_setting { 'director database ressource charset':
    setting => 'charset',
    value   => 'utf8',
  }

  if $install_method == 'git' {
    if $pkg_deps {
      package { $pkg_deps:
        ensure => $pkg_ensure,
        before => Vcsrepo['director'],
      }
    }

    vcsrepo { 'director':
      ensure   => present,
      path     => "${web_root}/modules/director",
      provider => 'git',
      revision => $git_revision,
      source   => $git_repo,
    }
  }

  exec { 'Icinga Director DB migration':
    path    => '/usr/local/bin:/usr/bin:/bin',
    command => 'icingacli director migration run',
    onlyif  => 'icingacli director migration pending',
    require => [Package['icingacli'],Ini_setting['director database']],
  }

  icinga2::object::apiuser { 'director':
    password  => cache_data('icinga2_cachedata', 'apiuser_director_password',
      random_password(32)),
    client_cn => 'director',
  } ->

  ini_setting { 'director kickstart endpoint':
    ensure  => present,
    require => File["${::icingaweb2::config_dir}/modules/director"],
    path    => "${::icingaweb2::config_dir}/modules/director/kickstart.ini",
    section => 'config',
    setting => 'endpoint',
    value   => $::fqdn,
  } ->
  ini_setting { 'director kickstart host':
    ensure  => present,
    require => File["${::icingaweb2::config_dir}/modules/director"],
    path    => "${::icingaweb2::config_dir}/modules/director/kickstart.ini",
    section => 'config',
    setting => 'host',
    value   => '127.0.0.1',
  } ->
  ini_setting { 'director kickstart username':
    ensure  => present,
    require => File["${::icingaweb2::config_dir}/modules/director"],
    path    => "${::icingaweb2::config_dir}/modules/director/kickstart.ini",
    section => 'config',
    setting => 'username',
    value   => 'director',
  } ->
  ini_setting { 'director kickstart password':
    ensure  => present,
    require => File["${::icingaweb2::config_dir}/modules/director"],
    path    => "${::icingaweb2::config_dir}/modules/director/kickstart.ini",
    section => 'config',
    setting => 'password',
    value   => cache_data('icinga2_cachedata', 'apiuser_director_password',
      random_password(32)),
  } ->

  exec { 'Icinga Director Kickstart':
    path    => '/usr/local/bin:/usr/bin:/bin',
    command => 'icingacli director kickstart run',
    onlyif  => 'icingacli director kickstart required',
    require => Exec['Icinga Director DB migration'],
  }
}
