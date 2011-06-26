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
# [match_destination]
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
  $match_destination = ['any'],
  $options = undef

  ) {

  $view_cfg_file = "${bind::bind_config_views_dir}/${name}"

  file { $view_cfg_file:
    content => template("${module_name}/view.conf"),
    notify => Exec["create_bind_views_conf"],
  }

}
