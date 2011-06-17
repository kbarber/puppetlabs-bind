# This resource manages zone configuration in Bind.
#
# The goal here is to setup the zone {}; configuration
# options in Bind as a puppet resource.
#
# == Parameters
#
# [name]
#   Name of zone.
# [type]
#   The type of zone.
# [class]
#   Class of zone. Usually IN.
# [file]
#   Path to zone file.
# [allow_update]
#   List of address to allow updates from.
# [custom_config]
#   The custom contents of the zone configuration.
#
# == Examples
#
#   bind::zone { "vms.cloud.bob.sh":
#     type => "master",
#     file => "vms.cloud.bob.sh.zone",
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
define bind::zone (

  $type = "master",
  $file = undef,
  $class = "IN",
  $allow_update = undef,
  $custom_config = undef

  ) {

  file { "${bind::params::bind_config_zones_dir}/${name}":
    content => template("${module_name}/zone.conf"),
    notify => Exec["create_bind_zones_conf"],
  }

}
