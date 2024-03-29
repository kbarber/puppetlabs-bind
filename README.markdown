# puppetlabs-bind module

This module manages Bind from within Puppet.

### Overview

This module is provided for the installation and configuration of ISC bind.

### Disclaimer

Warning! While this software is written in the best interest of quality it has 
not been formally tested by our QA teams. Use at your own risk, but feel free to 
enjoy and perhaps improve it while you do.

Please see the included Apache Software License for more legal details regarding 
warranty.

### Requirements

So this module was predominantly tested with:

* Puppet 2.7.0rc4
* Debian Wheezy
* Bind 9.7.3

Other combinations may work, and we are happy to obviously take patches to 
support other stacks.

# Installation

As with most modules, its best to access this module from the forge:

http://forge.puppetlabs.com/

If you want the bleeding edge (and potentially broken) version from github, 
download the module into your modulepath on your Puppetmaster. If you are not 
sure where your module path is try this command:

  puppet --configprint modulepath

Depending on the version of Puppet, you may need to restart the puppetmasterd 
(or Apache) process before the functions will work.

# Quick Start

To setup a new bind server with all the default settings:

    node "dns1" {
      class { "bind":
      }
    }

This of course on its own is useless without configuration.

You can create zones like this:

    node "dns1" {
      class { "bind":
      }
      bind::zone { "desktops.mydomain.com":
        type => "master",
        config => {
          file => "/var/lib/bind/desktops.mydomain.com.zone",
        }
      }
    }

The 'config' hash will take most settings that are acceptable according to the
BIND zone file grammar.

If you want to use views, then you can do this:

    node "dns1" {
      class { "bind":
      }
      bind::view { "external": }
      bind::view::zone { "external:desktops.mydomain.com":
        type => "master",
      }
    }

*Note:* You can't mix and match views and normal zones. If you choose to use
views, then make sure you always create zones using the bind::view::zone 
resource only.

To specify specific options to BIND when first configuring it, you can use the
options parameter:

    node "dns1" {
      class { "bind":
        options => {
          'allow-query' => ['192.168.1.2'],
          'statistics-interval => 60,
        }
      }
    }
    
This populates your global configuration.