#!/usr/bin/perl
#
#  make_regression_data
#
#  Created by Andy Armstrong on 2007-02-04.
#  Copyright (c) 2007 Hexten. All rights reserved.

use strict;
use warnings;
use Carp;
use version;
use Data::Dumper;

$| = 1;

my $MAX_DIGITS = 5;
my %got        = ();

my @list = map { get_fountain( $_ ) } 1 .. $MAX_DIGITS;
my @case = ();

srand( 1 );

while ( keys %got < 500 ) {
    my $pfx     = rand( 1 ) < 0.5;
    my $alp     = rand( 1 ) < 0.5;
    my $n_parts = int( rand( 5 ) ) + 1;
    my @parts   = ();
    for ( 1 .. $n_parts ) {

        # Generate part
        my $li = $list[ int( rand( $MAX_DIGITS ) ) ];
        my $po = int( rand( @$li ) );
        push @parts, $li->[$po];
    }
    my $ver = join( '.', @parts );
    $ver =~ s/[.](\d+)$/_$1/ if $alp;
    $ver = "v$ver" if $pfx;
    next if $got{$ver}++;

    my $rec = { version => $ver };
    my $err;

    my $vv = eval { qv( $ver ) };
    $rec->{qv} = {
        v => defined $vv && "$vv",
        te( $@, \$err ),
    };

    my $vo = eval { version->new( $ver ) };
    $rec->{new} = {
        v => defined $vo && "$vo",
        te( $@, \$err ),
    };

    if ( $vo ) {
        for my $method ( qw(stringify numify normal) ) {
            my $vv = eval { $vo->$method };
            $rec->{$method} = {
                v => defined $vv && "$vv",
                te( $@, \$err ),
            };
        }
    }

    push @case,
      {
        rec   => $rec,
        order => [ $pfx, $alp, $n_parts ],
        err   => $err,
      };
}

my $cmp = sub {
    if ( defined $a->{err} && defined $b->{err} ) {
        my $cmp = $a->{err} cmp $b->{err};
        return $cmp if $cmp;
    }

    return -1 if defined $a->{err};
    return 1  if defined $b->{err};

    my @al = @{ $a->{order} };
    my @bl = @{ $b->{order} };

    while ( @al ) {
        my $cmp = shift @al <=> shift @bl;
        return $cmp if $cmp;
    }

    return length( $a->{rec}->{version} ) <=> length( $b->{rec}->{version} )
      || $a->{rec}->{version} cmp $b->{rec}->{version};

};

my @reference =
  map { $_->{rec} }
  sort $cmp @case;

print Dumper( \@reference );

sub te {
    my $e    = shift;
    my $eref = shift;
    return unless $e;
    $e =~ s!\s+at\s+\S+?/\S+.*!!sm;
    $$eref = $e unless $$eref;
    return ( 'e' => $e );
}

sub get_fountain {
    my $digits = shift;
    my $start  = shift || 0;
    my $fmt    = "%0${digits}d";
    my @list   = ();

    push @list, sprintf( $fmt, 0 );
    for my $d ( 1 .. $digits ) {
        my ( $n, $nd ) = ( 0, $start );
        for ( 1 .. $d ) {
            $n = $n * 10 + chr( ord( '1' ) + ( $nd++ % 9 ) );
        }

        for my $shift ( 0 .. $digits - $d ) {
            push @list, sprintf( $fmt, $n * 10**$shift );
        }
    }

    return \@list;
}
