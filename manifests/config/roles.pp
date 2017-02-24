# Define for setting IcingaWeb2 Roles
#
define icingaweb2::config::roles (
  $role_groups                    = undef,
  $role_name                      = $title,
  $role_permissions               = undef,
  $role_monitoring_filter_objects = undef,
  $role_users                     = undef,
) {
  validate_string($role_name)

  Ini_Setting {
    ensure  => present,
    section => $role_name,
    require => File["${::icingaweb2::config_dir}/roles.ini"],
    path    => "${::icingaweb2::config_dir}/roles.ini",
  }

  if $role_users {
    validate_string($role_users)
    $role_users_ensure = present
  }
  else {
    $role_users_ensure = absent
  }

  ini_setting { "icingaweb2 roles ${title} users":
    ensure  => $role_users_ensure,
    setting => 'users',
    value   => "\"${role_users}\"",
  }

  if $role_groups {
    validate_string($role_users)
    $role_groups_ensure = present
  }
  else {
    $role_groups_ensure = absent
  }

  ini_setting { "icingaweb2 roles ${title} groups":
    ensure  => $role_groups_ensure,
    setting => 'groups',
    value   => "\"${role_groups}\"",
  }

  if $role_permissions {
    validate_string($role_permissions)
    $role_permissions_ensure = present
  }
  else {
    $role_permissions_ensure = absent
  }

  ini_setting { "icingaweb2 roles ${title} permissions":
    ensure  => $role_permissions_ensure,
    setting => 'permissions',
    value   => "\"${role_permissions}\"",
  }

  if $role_monitoring_filter_objects {
    validate_string($role_monitoring_filter_objects)
    $role_monitoring_filter_objects_ensure = present
  }
  else {
    $role_monitoring_filter_objects_ensure = absent
  }

  ini_setting { "icingaweb2 roles ${title} monitoring filter objects":
    ensure  => $role_monitoring_filter_objects_ensure,
    setting => 'monitoring/filter/objects',
    value   => "\"${role_monitoring_filter_objects}\"",
  }
}
