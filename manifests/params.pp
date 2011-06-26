# Bind parameter class. This provides variables to the bind module.
# Not to be used directly.
#
# === OS Support
#
# For now we cover:
#
# * Debian
# * Ubuntu
#
# == Variables
#
# This is a list of variables that must be set for each operating system.
# 
# [bind_package]
#   Package(s) for installing the server.
# [bind_service]
#   Service name for bind.
# [bind_config}
#   Main bind configuration file.
# [bind_config_dir]
#   Path to main bind configuration directory.
# [bind_config_zones]
#   Path to zone configuration file.
# [bind_config_zones_dir]
#   Path to zone directory where we assemble zones.
# [bind_config_views]
#   Path to view configuration file.
# [bind_config_views_dir]
#   Path to view directory where we assemble views.
# [bind_config_viewzones_dir]
#   Path to per-view zones directory.
# [bind_config_local]
#   Path to local file we can use for our own work.
# [bind_config_options]
#   Path to options file.
# [bind_cache_dir]
#   Directory where cache items are kept.
# [bind_data_dir]
#   Path to BIND data directory.
# [bind_data_zones_dir]
#   Path to BIND zones data directory.
# [bind_user]
#   User that bind runs as.
# [bind_group]
#   Group that bind user belongs to.
# [bind_config_local_content]
#   Content of the BIND local file.
#
# == Authors
#
# Ken Barber <ken@bob.sh>
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class bind::params {

  case $operatingsystem {
    'ubuntu', 'debian': {
      $bind_package = "bind9"
      $bind_service = "bind9"
      $bind_config_dir = "/etc/bind"
      $bind_config = "${bind_config_dir}/named.conf"
      $bind_config_zones = "${bind_config_dir}/named.conf.zones"
      $bind_config_zones_dir = "${bind_config_dir}/zones.d"
      $bind_config_views = "${bind_config_dir}/named.conf.views"
      $bind_config_views_dir = "${bind_config_dir}/views.d"
      $bind_config_viewzones_dir = "${bind_config_dir}/viewzones.d"
      $bind_config_local = "${bind_config_dir}/named.conf.local"
      $bind_config_options = "${bind_config_dir}/named.conf.options"
      $bind_cache_dir = "/var/cache/bind"
      $bind_data_dir = "/var/lib/bind"
      $bind_data_zones_dir = "${bind_data_dir}/zones"
      $bind_user = "bind"
      $bind_group = "bind"

      # Content templates last (so over vars can be used)
      $bind_config_local_content = template("${module_name}/debian/named.conf.local")
    }
    default: {
      fail("Operating system ${operatingsystem} is not supported")
    }
  }
}
