#!/usr/bin/perl

use strict;
use warnings;
use lib qw(lib);
use Perl::Version::Mutable;
use Data::Dumper;
use Perl::Tidy;

$| = 1;

while ( defined( my $ver = shift ) ) {
    my $version = Perl::Version::Mutable->new( $ver );
    my $dump    = Data::Dumper->Dump( [$version], ['$version'] );
    my $tidy    = '';
    Perl::Tidy::perltidy(
        source      => \$dump,
        destination => \$tidy,
    );

    print "$tidy\n";
}
