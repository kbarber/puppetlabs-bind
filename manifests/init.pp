# Install and configure ISC Bind.
#
# == Parameters
#
# Detailed customisation parameters below. You shouldn't normally need to change
# these as we try to look them up ourselves.
# 
# [bind_package]
#   *Optional* The name(s) of packages to install for bind.
# [bind_service]
#   *Optional* Service to use for starting bind.
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

  $bind_package = $bind::params::bind_package,
  $bind_service = $bind::params::bind_service,
  $bind_config_dir = $bind::params::bind_config_dir,
  $bind_config_local = $bind::params::bind_config_local,
  $bind_config_local_content = $bind::params::bind_config_local_content,
  $bind_config_zones = $bind::params::bind_config_zones,
  $bind_config_zones_dir = $bind::params::bind_config_zones_dir,
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
