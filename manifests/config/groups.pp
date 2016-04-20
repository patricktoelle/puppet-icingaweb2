# Define for setting IcingaWeb2 Groups
#
define icingaweb2::config::groups (
  $group_name          = $title,
  $group_resource      = undef,
  $group_user_backend  = undef,
  $group_base_dn       = undef,
  $group_backend       = undef,
) {
  validate_string($group_name)

  Ini_Setting {
    ensure  => present,
    section => $group_name,
    require => File["${::icingaweb2::config_dir}/groups.ini"],
    path    => "${::icingaweb2::config_dir}/groups.ini",
  }

  if $group_resource {
    validate_string($group_resource)
    $group_resource_ensure = present
  }
  else {
    $group_resource_ensure = absent
  }

  ini_setting { "icingaweb2 group ${title} resource":
    ensure  => $group_resource_ensure,
    setting => 'resource',
    value   => "\"${group_resource}\"",
  }

  if $group_user_backend {
    validate_string($group_user_backend)
    $group_user_backend_ensure = present
  }
  else {
    $group_user_backend_ensure = absent
  }

  ini_setting { "icingaweb2 roles ${title} user backend":
    ensure  => $group_user_backend_ensure,
    setting => 'user_backend',
    value   => "\"${group_user_backend}\"",
  }

  if $group_base_dn {
    validate_string($group_base_dn)
    $group_base_dn_ensure = present
  }
  else {
    $group_base_dn_ensure = absent
  }

  ini_setting { "icingaweb2 roles ${title} base_dn":
    ensure  => $group_base_dn_ensure,
    setting => 'base_dn',
    value   => "\"${group_base_dn}\"",
  }

  if $group_backend {
    validate_string($group_backend)
    $group_backend_ensure = present
  }
  else {
    $group_backend_ensure = absent
  }

  ini_setting { "icingaweb2 roles ${title} backend":
    ensure  => $group_backend_ensure,
    setting => 'backend',
    value   => "\"${group_backend}\"",
  }
}
