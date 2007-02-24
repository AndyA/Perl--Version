#!/usr/bin/perl

use strict;
use warnings;
use lib qw(lib);
use Perl::Version;
use Data::Dumper;

while ( my $ver = shift ) {
    print "$ver\n";
    my $obj = Perl::Version->new( $ver );
    print Dumper( $obj );
    for my $meth ( qw ( stringify normal numify ) ) {
        printf("%9s: '%s'\n", $meth, $obj->$meth);
    }
}
