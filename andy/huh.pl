#!/usr/bin/perl

use strict;
use warnings;
use Carp;
use lib qw(lib);
use Perl::Version qw(qv);
use version;
use Data::Dumper;
use Term::ANSIColor;

my @vers = qw(
 1 1.2 1.23 1.2.3 1.2.34 1.2.3.4 1.2.3.4.5 1.2.3.4.5.6
 v1 v1.2 v1.2.3 v1.2.3.4 v1.2.3.4.5 v1.2.3.4.5.6
 1_02 1_002 1_2 1_23 1_234 1_2345 1_23456
 1.2_03 1.2_30 1.2_003 1.2_030 1.2_300 1.2_3 1.2_34 1.2_345 1.2_3456 1.2_34567
 1.2.3_4 1.2.3_45 1.2.3_456 1.2.3_4567 1.2.3_45678
 1.2.3.4_5 1.2.3.4_56 1.2.3.4_567 1.2.3.4_5678 1.2.3.4_56789
 1.002 1.002003 1.002003004
 1.020 1.020030 1.020030040
 1.200 1.200300 1.200300400
 1.203 1.203405 1.203405607
 1.23_01 5.005_03
);

my @cl = qw(
 version Perl::Version
);

my @meth = qw(
 stringify numify
);

my @row = ( 'literal' );
my $fw  = 0;
for my $meth ( @meth ) {
  for my $cl ( @cl ) {
    my $cap = "$cl->$meth";
    my $cl  = length( $cap );
    $fw = $cl if $fw < $cl;
    push @row, $cap;
  }

}

my $fmt = join( ' | ', map { "%-${fw}s" } 0 .. ( @cl * @meth ) );
my $hdr = sprintf( "$fmt", @row );
my $bar = '=' x length( $hdr );

print "$bar\n$hdr\n$bar\n";

for my $v ( @vers ) {
  my @row = ();
  for my $meth ( @meth ) {
    for my $cl ( @cl ) {
      my $vv = eval { $cl->new( $v ) };
      if ( $@ ) {
        push @row, substr( $@, 0, $fw );
      }
      else {
        push @row, $vv ? $vv->$meth : '(undef)';
      }
    }
  }
  for my $col ( 0 .. $#row ) {
    if ( $row[$col] ne $row[ $col ^ 1 ] ) {
      $row[$col] = colored( $row[$col], 'red' );
    }
  }
  unshift @row, $v;
  printf( "$fmt\n", @row );
}
print "$bar\n";
