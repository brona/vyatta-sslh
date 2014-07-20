#!/usr/bin/perl
#
# Module: vyatta-show-sslh.pl
#
# **** License ****
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# This code was originally developed by Ubiquiti, Inc.
# Portions created by Ubiquiti are Copyright (C) 2011 Ubiquiti, Inc.
# All Rights Reserved.
#
# Author: Bronislav Robenek <brona@robenek.me>
# Author: Dominik Malis <d.malis@sh.cvut.cz>
# Date: July 2014
# Description: Script to configure sslh
#
# **** End License ****

use strict;
use warnings;

use lib '/opt/vyatta/share/perl5';
use Vyatta::Config;

my $config_path = 'service ssl-port-sharing';
my $config = new Vyatta::Config;
$config->setLevel($config_path);

my $pidfile  = '/var/run/sslh.pid';
my $pid = `cat $pidfile`;
chomp $pid;
my $pid_running = 0;

if ( -e "/proc/$pid/status") {
  $pid_running = 1;
}

if ( $pid_running ) {
  print "SSL Port-sharing IS operational (PID = $pid).\n";
  my $port = $config->returnOrigValue('port');
  my $address = "0.0.0.0";
  my $mode = $config->returnOrigValue('mode');
  print "Forwarding in $mode mode from $address:$port to:\n\n";

  my $format = "%-10s %-20s %-6s\n";
  printf($format, "Protocol","IP Address","Port");
  printf($format, "--------","------------------","-----");

  my @protocols = $config->listOrigNodes('protocol');
  foreach my $prot (@protocols) {
      $config->setLevel("$config_path protocol $prot");
      my $a = $config->returnOrigValue('address');
      my $p    = $config->returnOrigValue('port');
      printf($format, $prot, $a, $p);
    }
}
else {
    $config->setLevel("");
    if ($config->existsOrig($config_path)) {
        if($config->existsOrig("$config_path disable")) {
            print "SSL Port-sharing IS DISABLED.\n";
        }
        else {
            print "SSL Port-sharing IS NOT running.\n";
        }
    }
    else {
        print "SSL Port-sharing IS NOT configured.\n";
    }
}

exit;
# end of file
