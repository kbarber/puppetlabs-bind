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
  $zone_file = "${bind::bind_data_zones_dir}/${name}.zone",
  $class = "IN",
  $allow_update = undef,
  $custom_config = undef,
  $zone_contact = "hostmaster@${name}",
  $nameservers = [ $fqdn ]

  ) {

  $zone_cfg_file = "${bind::bind_config_zones_dir}/${name}"
  $zone_contact_dns = regsubst($zone_contact, "@", ".")
  $rndc_reload_exec = "rndc_reload_${name}"

  # Create sample content
  file { $zone_file:
    replace => false,
    owner => $bind::bind_user,
    group => $bind::bind_group,
    mode => "0644",
    content => template("${module_name}/sample.zone"),
    before => File[$zone_cfg_file],
    notify => $allow_update ? {
      undef => Exec[$rndc_reload_exec],
      default => undef
    }
  }

  file { $zone_cfg_file:
    content => template("${module_name}/zone.conf"),
    notify => Exec["create_bind_zones_conf"],
  }

  exec { $rndc_reload_exec:
    refreshonly => true,
    command => "rndc reload ${name}",
    path => "/usr/sbin",
    require => Service[$bind::bind_service],
  }

}
