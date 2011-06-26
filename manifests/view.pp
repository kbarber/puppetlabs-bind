# This resource manages view configuration in Bind.
#
# The goal here is to setup the view {}; configuration
# options in Bind as a puppet resource. Views are used
# to provide different query results to different clients
# based on IP subnet matches.
#
# == Parameters
#
# [name]
#   Name of view.
# [class]
#   Class of view. Usually IN.
# [match_clients]
#   An array of clients to match. Default value is 'any'.
# [match_destinations]
#   An array of destinations to match. Default value is 'any'.
# [options]
#   An array of options to configure the view.
#
# == Examples
#
# The following basic example will allow you to create an internal view.
#
#   bind::view { "internal":
#     match_clients => ["192.168.1.0/24"],
#     options => {
#     }
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
define bind::view (

  $class = "IN",
  $match_clients = ['any'],
  $match_destinations = ['any'],
  $options = undef

  ) {

  $view_cfg_file = "${bind::bind_config_views_dir}/${name}.conf"
  file { $view_cfg_file:
    content => template("${module_name}/view.conf"),
    notify => Exec["create_bind_views_conf"],
    require => File["${bind::bind_config_viewzones_dir}/${name}.zones.conf"],
  }

  #########
  # Zones #
  #########
  $view_cfg_zones_dir = "${bind::bind_config_viewzones_dir}/${name}"
  file { $view_cfg_zones_dir:
  	ensure => directory,
  	recurse => true,
  	purge => true,
  	notify => Exec["create_bind_viewzones_conf_${name}"]
  }
  file { "${view_cfg_zones_dir}/00_header.conf":
    content => "# File managed by Puppet\n",
    notify => Exec["create_bind_viewzones_conf_${name}"],
  }
  exec { "create_bind_viewzones_conf_${name}":
    command => "/bin/cat ${view_cfg_zones_dir}/*.conf > ${bind::bind_config_viewzones_dir}/${name}.zones.conf",
    refreshonly => true,
    require => [ Package[$bind::bind_package], File[$bind::bind_config_views_dir] ],
    notify => Service[$bind::bind_service],
  }
  file { "${bind::bind_config_viewzones_dir}/${name}.zones.conf":
    ensure => present,
    owner => "root",
    group => "root",
  }
}
