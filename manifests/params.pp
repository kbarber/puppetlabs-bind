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
    }
    default: {
      fail("Operating system ${operatingsystem} is not supported")
    }
  }
}
