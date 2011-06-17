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
# [bind_config_dir]
#   Path to main bind configuration directory.
# [bind_config_local]
#   Path to local file we can use for our own work.
# [bind_config_local_content]
#   Contents of local configuration file.
# [bind_user]
#   User that bind runs as.
# [bind_group]
#   Group that bind user belongs to.
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
      $bind_config_local = "${bind_config_dir}/named.conf.local"
      $bind_config_local_content = template("${module_name}/debian/named.conf.local")
      $bind_user = "bind"
      $bind_group = "bind"
    }
    default: {
      fail("Operating system ${operatingsystem} is not supported")
    }
  }
}
