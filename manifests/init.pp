# Install and configure ISC Bind.
#
# == Parameters
#
# [options]
#   A hash of global options for bind.
#
# Detailed customisation parameters below. You shouldn't normally need to change
# these as we try to look them up ourselves.
# 
# [bind_package]
#   *Optional* The name(s) of packages to install for bind.
# [bind_service]
#   *Optional* Service to use for starting bind.
# [bind_config]
#   *Optional* Main bind configuration file.
# [bind_config_dir]
#   *Optional* Path to main bind configuration directory.
# [bind_config_local]
#   *Optional* Path to local file we can use for our own work.
# [bind_config_local_content]
#   *Optional* The contents to install in $bind_config_local
# [bind_config_zones]
#   *Optional* Path to the file where we place all zone configuration.
# [bind_config_zones_dir]
#   *Optional* Path to zone directory where individual zones configuration is kept for munging.
# [bind_config_views]
#   *Optional* Path to the file where we place all view configuration.
# [bind_config_views_dir]
#   *Optional* Path to view directory where individual zones configuration is kept for munging.
# [bind_config_viewzones_dir]
#   *Optional* Path to per-view zone directories.
# [bind_config_options]
#   *Optional* Path to options file.
# [bind_data_dir]
#   *Optional* Path to the bind data directory (zones belong here for example).
# [bind_data_zones_dir]
#   *Optional* Path to data directory where zone files are usually kept.
# [bind_user]
#   *Optional* Bind user
# [bind_group]
#   *Optional* Bind group
#
# == Variables
#
# N/A
#
# == Examples
#
# Basic configuration:
#
#   class { "bind":
#   }
#
# == Authors
#
# Ken Barber <ken@bob.sh>
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class bind (

  $options = {},
  $bind_package = $bind::params::bind_package,
  $bind_service = $bind::params::bind_service,
  $bind_config = $bind::params::bind_config,
  $bind_config_dir = $bind::params::bind_config_dir,
  $bind_config_local = $bind::params::bind_config_local,
  $bind_config_local_content = $bind::params::bind_config_local_content,
  $bind_config_zones = $bind::params::bind_config_zones,
  $bind_config_zones_dir = $bind::params::bind_config_zones_dir,
  $bind_config_views = $bind::params::bind_config_views,
  $bind_config_views_dir = $bind::params::bind_config_views_dir,
  $bind_config_viewzones_dir = $bind::params::bind_config_viewzones_dir,
  $bind_config_options = $bind::params::bind_config_options,
  $bind_cache_dir = $bind::params::bind_cache_dir,
  $bind_data_dir = $bind::params::bind_data_dir,
  $bind_data_zones_dir = $bind::params::bind_data_zones_dir,
  $bind_user = $bind::params::bind_user,
  $bind_group = $bind::params::bind_group

  ) inherits bind::params {

  ############
  # Packages #
  ############
  package { $bind_package:
    ensure => installed,
    notify => Service[$bind_service],
  }

  #################
  # Configuration #
  #################
  file { $bind_config:
    content => template("${module_name}/named.conf"),
    owner => root,
    group => $bind_group,
    mode => "0644",
    require => Package[$bind_package],
    notify => Service[$bind_service],
  }

  file { $bind_config_local:
    content => $bind_config_local_content,
    owner => root,
    group => $bind_group,
    mode => "0644",
    require => Package[$bind_package],
    notify => Service[$bind_service],
  }

  ########################
  # Configuration: Zones #
  ########################
  file { $bind_config_zones:
    owner => root,
    group => $bind_group,
    mode => "0644",
    require => Package[$bind_package],
    notify => Service[$bind_service],
  }
  file { $bind_config_zones_dir:
    ensure => directory,
    purge => true,
    recurse => true,
    require => Package[$bind_package],
    notify => Exec["create_bind_zones_conf"],
  }
  file { "${bind_config_zones_dir}/00_header":
    content => "# File managed by Puppet\n",
    notify => Exec["create_bind_zones_conf"],
  }
  exec { "create_bind_zones_conf":
    command => "/bin/cat ${bind_config_zones_dir}/* > ${bind_config_zones}",
    refreshonly => true,
    require => [ Package[$bind_package], File[$bind_config_zones_dir] ],
    notify => Service[$bind_service],
  }

  # Storage area for zones
  file { $bind_data_zones_dir:
    ensure => directory,
    owner => $bind_user,
    group => $bind_group,
    mode => "0755",
  }

  ########################
  # Configuration: views #
  ########################
  file { $bind_config_views:
    owner => root,
    group => $bind_group,
    mode => "0644",
    require => Package[$bind_package],
    notify => Service[$bind_service],
  }
  file { $bind_config_views_dir:
    ensure => directory,
    purge => true,
    recurse => true,
    require => Package[$bind_package],
    notify => Exec["create_bind_views_conf"],
  }
  file { "${bind_config_views_dir}/00_header.conf":
    content => "# File managed by Puppet\n",
    notify => Exec["create_bind_views_conf"],
  }
  exec { "create_bind_views_conf":
    command => "/bin/cat ${bind_config_views_dir}/*.conf > ${bind_config_views}",
    refreshonly => true,
    require => [ Package[$bind_package], File[$bind_config_views_dir] ],
    notify => Service[$bind_service],
  }
  file { $bind_config_viewzones_dir:
    ensure => directory,
    purge => true,
    recurse => true,
    require => Package[$bind_package],
  }

  ##########################
  # Configuration: Options #
  ##########################
  if(!defined($options["auth-nxdomain"])) {
    $options["auth-nxdomain"] = "no"
  }
  if(!defined($options["listen-on-v6"])) {
    $options["listen-on-v6"] = ["any"]
  }
  if(!defined($options["directory"])) {
    $options["directory"] = $bind_cache_dir
  }
  file { $bind_config_options:
    content => template("${module_name}/options.conf"),
    owner => "root",
    group => $bind_group,
    mode => "0644",
    notify => Service[$bind_service],
  }

  ############
  # Services #
  ############
  service { $bind_service:
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

}
