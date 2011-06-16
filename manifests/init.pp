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
  $bind_service = $bind::params::bind_service

  ) inherits bind::params {

  ############
  # Packages #
  ############
  package { $bind_package:
    ensure => installed,
    notify => Service[$bind_service],
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
