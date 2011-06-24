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
# [zone_contact]
#   Email address of contact for the zone.
# [nameservers]
#   Name servers for zone.
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
  $zone_file = "${bind::params::bind_data_zones_dir}/${name}.zone",
  $class = "IN",
  $allow_update = undef,
  $custom_config = undef,
  $zone_contact = "hostmaster@${name}",
  $nameservers

  ) {

  $zone_cfg_file = "${bind::params::bind_config_zones_dir}/${name}"
  $zone_contact_dns = regsubst($zone_contact, "@", ".")

  # Create sample content
  file { $zone_file:
    replace => false,
    owner => $bind::bind_user,
    group => $bind::bind_group,
    mode => "0644",
    content => template("bind/sample.zone"),
    before => File[$zone_cfg_file],
    notify => Service[$bind::bind_service],
  }

  file { $zone_cfg_file:
    content => template("${module_name}/zone.conf"),
    notify => Exec["create_bind_zones_conf"],
  }

}
