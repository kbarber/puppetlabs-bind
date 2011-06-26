# This resource manages zone configuration inside a view in Bind.
#
# The goal here is to setup the zone {}; configuration inside an
# existing view.
#
# == Parameters
#
# [name]
#   Name of view & zone delimited by a colon.
# [type]
#   The type of zone.
# [class]
#   Class of zone. Usually IN.
# [zone_contact]
#   Email address of contact for the zone.
# [nameservers]
#   Name servers for zone.
# [options]
#   A hash of options to configure the zone.
#
# == Examples
#
#   bind::view::zone { "internal:vms.cloud.bob.sh":
#     type => "master",
#     options => {
#       file => "vms.cloud.bob.sh.zone",
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
define bind::view::zone (

  $type = "master",
  $class = "IN",
  $zone_contact = "hostmaster@${name}",
  $nameservers = [ $fqdn ],
  $options = undef

  ) {
  	
  $namesplit = split($name, ":")
  $view = $namesplit[0]
  $zone = $namesplit[1]
  
  # Always require the view to be configured first
  require(Bind::View[$view])

  if(!defined($options['file'])) {
    $options['file'] = "${bind::bind_data_zones_dir}/${name}.zone"
  }

  $zone_cfg_file = "${bind::bind_config_zones_dir}/${name}"
  $zone_contact_dns = regsubst($zone_contact, "@", ".")
  $rndc_reload_exec = "rndc_reload_${name}"

  # Create sample content
  $zone_file = $options['file']
  file { $zone_file:
    replace => false,
    owner => $bind::bind_user,
    group => $bind::bind_group,
    mode => "0644",
    content => template("${module_name}/sample.zone"),
    before => File[$zone_cfg_file],
    notify => $options["allow-update"] ? {
      undef => Exec[$rndc_reload_exec],
      default => undef
    }
  }

  file { $zone_cfg_file:
    content => template("${module_name}/zone.conf"),
    notify => Exec["create_bind_viewzones_conf_${view}"],
  }

  exec { $rndc_reload_exec:
    refreshonly => true,
    command => "rndc reload ${zone} ${class} ${view}",
    path => "/usr/sbin",
    require => Service[$bind::bind_service],
  }

}
