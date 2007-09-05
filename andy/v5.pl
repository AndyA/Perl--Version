#!/usr/bin/perl

use strict;
use warnings;
use lib qw<lib>;
use Perl::Version;

$| = 1;

my $ver = Perl::Version->new( '5.00504' );
print "$ver\n";
$ver->increment( 2 );
print "$ver\n";
