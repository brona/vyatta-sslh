# vyatta-sslh

This package provides Vyatta/VyOS/EdgeOS [SSLH](http://www.rutschle.net/tech/sslh.shtml) configuration, templates and scripts.

SSLH is SSL multiplexer which provides port-sharing of same TCP port for multiple applications - more information at http://www.rutschle.net/tech/sslh.shtml

## Authors

* Bronislav Robenek <brona@robenek.me>
* Dominik Malis <d.malis@sh.cvut.cz>

Used software:

* Configuration script is derived from [ubnt-igmpproxy](http://www.ubnt.com/download/) script by Stig Thormodsrud from Ubiquiti Networks, Inc.
* Vyatta/VyOS package is based on [vyatta-dummy](https://github.com/vyos/vyatta-dummy) package by SO3 Group, including Daniil Baturin.

## Supported versions

Tested with:

* sslh (1.16) from jessie, backported to squeeze
* VyOS 1.1.3 helium

## Usage

Example Vyatta/VyOS/EdgeOS configuration:

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

Example result of show command:

    $ show ssl-port-sharing
    SSL Port-sharing IS operational (PID = 9234).
    Forwarding in select mode from 0.0.0.0:1234 to:

    Protocol   IP Address           Port
    --------   ------------------   -----
    http       192.168.1.5          443
    openvpn    127.0.0.1            1194
    ssh        192.168.1.10         22

## Installation of SSLH in VyOS/Vyatta/EdgeOS

It is not easy to install recent software including sslh add vyatta-sslh package into VyOS. The only way to install `sslh-1.16` is to create backport and recompile package for your distribution/architecture. Debian has [SimpleBackportCreation](https://wiki.debian.org/SimpleBackportCreation) manual.

Since I already did this please feel free to use this source/binary, however be aware that no guarantees are provided.

Either way you need some dependencies from squeeze/squeeze-lts, so you should add these:

        set system package repository squeeze components 'main contrib non-free'
        set system package repository squeeze distribution 'squeeze'
        set system package repository squeeze url 'http://mirrors.kernel.org/debian'

        set system package repository squeeze-lts components 'main contrib non-free'
        set system package repository squeeze-lts distribution 'squeeze-lts'
        set system package repository squeeze-lts url 'http://mirrors.kernel.org/debian'

During sslh instalation choose `standalone`, and then disable automatic startup:

    $ sudo update-rc.d -f sslh remove

### A) Use custom repository
This repository is only temporary and is provided as-is with no guarantees. sslh may be once formaly backported into squeeze-backports-sloppy.

    $ echo "deb http://packages.robenek.me debian/" > /etc/apt/sources.list.d/robenek.list
    $ sudo apt-get update
    $ sudo apt-get install sslh

### B) Use downloaded .deb file

    $ wget http://packages.robenek.me/debian/sslh_1.16-2~bpo60+1_amd64.deb
    $ dpkg -i sslh_1.16-2~bpo60+1_amd64.deb

### C) Compile from prepared source

    $ wget http://packages.robenek.me/debian/sslh_1.16-2~bpo60+1.tar.gz
    $ # Extract, install build-dep, etc...
    $ dpkg-buildpackage -us -uc

### D) Create your own backported package

    $ dget -x http://ftp.de.debian.org/debian/pool/main/s/sslh/sslh_1.16-2.dsc
    $ # Extract, install build-dep, etc...
    $ # Edit debian/rules, debian/compat, debian/control
    $ fakeroot debian/rules binary
    $ dpkg-buildpackage -us -uc

## Installation of vyatta-sslh in VyOS/Vyatta/EdgeOS

### A) Use custom repository
This repository is only temporary and is provided as-is with no guarantees. vyatta-sslh may be once integrated into VyOS community repository.

    $ echo "deb http://packages.robenek.me debian/" > /etc/apt/sources.list.d/robenek.list
    $ sudo apt-get update
    $ sudo apt-get install vyatta-sslh

### B) Use downloaded .deb file

    $ wget http://packages.robenek.me/debian/vyatta-sslh_1.0.2_all.deb
    $ sudo dpkg -i vyatta-sslh_1.0.2_all.deb

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

* Specify sslh binding (currently to 0.0.0.0 only).
* There is no support for transparent mode of sslh.
* Binary package for EdgeOS
