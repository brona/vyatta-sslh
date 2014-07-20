# vyatta-sslh

This package provides Vyatta/VyOS [http://www.rutschle.net/tech/sslh.shtml](SSLH) configuration, templates and scripts.

SSLH is SSL multiplexer which provides port-sharing of same TCP port for multiple applications - more information at http://www.rutschle.net/tech/sslh.shtml

## Authors

* Bronislav Robenek <brona@robenek.me>
* Dominik Malis <d.malis@sh.cvut.cz>

Used software:

* Configuration script is derived from [ubnt-igmpproxy](http://www.ubnt.com/download/) script by Stig Thormodsrud from Ubiquiti Networks, Inc.
* Vyatta/VyOS package is based on [vyatta-dummy](https://github.com/vyos/vyatta-dummy) package by SO3 Group, including Daniil Baturin.

## Supported versions

Tested with:

* sslh (1.15-1) from jessie
* VyOS 1.0.4 hydrogen

## Usage

Example Vyatta/VyOS configuration:

    service {
      ssl-port-sharing {
        mode select
        port 443
        protocol http {
          address 192.168.1.5
          port 443
        }
        protocol openvpn {
          address 127.0.0.1
          port 1194
        }
        protocol ssh {
          address 192.168.1.10
          port 22
        }
      }
    }

## Installation of SSLH in VyOS/Vyatta

To easily install recent software including sslh add jessie and squeeze (optional) repository to VyOS/Vyatta.

    # set system package repository jessie components 'main'
    # set system package repository jessie distribution 'jessie'
    # set system package repository jessie url 'http://mirrors.kernel.org/debian'

    # set system package repository squeeze components 'main'
    # set system package repository squeeze distribution 'squeeze'
    # set system package repository squeeze url 'http://mirrors.kernel.org/debian'
    # commit

To install only single package (eg. sslh) it is reasonable idea to pin current packages:

    $ cat /etc/apt/preferences
    Package: *
    Pin: release n=hydrogen
    Pin-Priority: 1000

    $ cat /etc/apt/preferences.d/squeeze.pref
    Package: *
    Pin: release n=squeeze
    Pin-Priority: 700

    $ cat /etc/apt/preferences.d/jessie.pref
    Package: *
    Pin: release n=jessie
    Pin-Priority: 90

Then update & upgrade system - be careful no packages should be upgraded.

    # Should proceed with no problems
    $ sudo apt-get update

    # Verify priorities
    $ sudo apt-cache policy

    # Almost no or zero packages should be upgraded
    $ sudo apt-get upgrade

A) Install sslh from jessie (with dependencies):

    # You will be asked about installation/upgrade plan
    $ sudo apt-get -t jessie install sslh

B) Install sslh from jessie (one by one package):

    # You will have to selectively upgrade unmet dependencies (eg. libc6)
    $ sudo apt-get install sslh/jessie

## Installation of vyatta-sslh in VyOS/Vyatta

### Disabling Debian sslh init.d script

    $ sudo update-rc.d -f sslh remove

### A) Use custom repository
This repository is only temporary and is provided as-is with no guarantees. vyatta-sslh may be once integrated into VyOS community repository.

    $ echo "deb http://packages.robenek.me debian/" > /etc/apt/sources.list.d/robenek.list
    $ sudo apt-get update
    $ sudo apt-get install vyatta-sslh

### B) Use downloaded .deb file

    $ wget http://packages.robenek.me/debian/vyatta-sslh_1.0.0_all.deb
    $ sudo dpkg -i vyatta-sslh_1.0.0_all.deb

### C) Compile from source

    $ aptitude install build-essential devscripts debhelper autotools-dev autoconf fakeroot automake
    $ git clone https://github.com/brona/vyatta-sslh
    $ cd vyatta-sslh
    $ debuild -us -uc

## Technical details

This package is just a wrapper for sslh.

Configuration is written to `/etc/sslh.conf`.

sslh is started using `start-stop-daemon`.

## Unsupported features / future development
We would like to encourage anyone to contribute to this package. We will be glad to accept pull-requests.

Currently these features are missing:

* sslh is binding to 0.0.0.0 only (there is no option).
* There is no support for transparent mode of sslh.

