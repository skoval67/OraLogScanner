#!/usr/bin/perl -w

use warnings;
use strict;
use IO::Select;

my $info = \*STDIN;
my $fs_count = 0;
my $dat_i = 0;
my $sock_i = 0;
my @FailedSockets = ();

if ( not IO::Select->new(\*STDIN)->can_read(0.1) ) {

  my $FileName=$ARGV[0];  
  if (not defined $FileName) {
    die "Need filename\n";
  };

  open $info, $FileName or die "Could not open $FileName: $!";
}

while( <$info> ) {

  if ( /(Fatal NI connect error [0-9]{1,5})/ ) {
    $FailedSockets[$fs_count++][2] = $1;
    
    while ( <$info> ) {
      if ( /(Fatal NI connect error [0-9]{1,5})/ ) {
        $FailedSockets[$fs_count++][2] = $1;
        next;
      };
      if ( /^\s*Time:\s*(.+)$/ and $dat_i < $fs_count ) {
        ($FailedSockets[$dat_i++][0]) = $1;
      };
      if ( /=tcp\)(.+?\))\)/i and $sock_i < $fs_count) {
        ($FailedSockets[$sock_i++][1]) = $1;
      }
      last if ( $dat_i == $fs_count and $sock_i == $fs_count);
    }
  };
}

close $info;

for my $row (0 .. $#FailedSockets) {
  printf("%s;%s;%s\n", $FailedSockets[$row][0], $FailedSockets[$row][1], $FailedSockets[$row][2]);
};
