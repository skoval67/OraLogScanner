#!/usr/bin/perl -w

use warnings;
use strict;
use IO::Select;

my $socket;
my $host;
my $port;
my $dat;

if ( not IO::Select->new(\*STDIN)->can_read(0.1) ) {
  die "Usage: find /dirs -type f -name 'log*.xml' | $0\n";
};

while (<>) {
  open my $info, $_ or die "Could not open $_: $!";
  
  local $/ = "</msg>";  
  while (<$info>) {
    ($dat, $host, $port) = /<txt>(.+?)\s\*.+HOST=([0-9\.]+)\)\(PORT=([0-9]+)/;
    ($socket) = /=tcp\)(.*)\)/;
    if (defined $dat) {
      printf("%s;%s;%s;%s\n", $dat, $host, $port, $socket);
    };
  };

  close $info;  
};
