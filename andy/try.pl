#!/usr/bin/perl

use strict;
use warnings;
use lib 'lib';
use version;
use Perl::Version;
use Data::Dumper;
use Storable;
use Getopt::Long;

#use Term::ANSIColor;

my $STORE = 'try.store';

my @method  = qw( stringify numify normal );
my @classes = qw( version Perl::Version );

my ( $dump, $load ) = @_;

GetOptions(
  'dump' => \$dump,
  'load' => \$load,
) or die "try -dump > file | -load < file | version ...\n";

if ( $dump ) {
  my $cases = retrieve( $STORE );
  print Data::Dumper->Dump( [$cases], ['$cases'] );
}
elsif ( $load ) {
  my $cases;
  local $/;
  my $data = <>;
  eval $data;
  die $@ if $@;
  store( $cases, $STORE );
}
else {
  my $cases = {};
  if ( -e $STORE ) {
    $cases = retrieve( $STORE );
  }

  if ( @ARGV ) {
    while ( defined( my $version = shift ) ) {
      my ( $table, $failed ) = try_version( $version );
      show_table( $table, 50 );
      $cases->{$version} = $failed;
    }
  }
  else {
    my %score = ();
    for my $version ( sort keys %$cases ) {
      my ( $table, $failed ) = try_version( $version );
      $cases->{$version} = $failed;
      if ( $failed ) {
        show_table( $table, 50 );
        $score{bad}++;
      }
      else {
        $score{ok}++;
      }
    }

    my @scores = ();
    for my $type ( sort keys %score ) {
      push @scores, "$type: $score{$type}";
    }
    if ( @scores ) {
      print "Results: ", join( ', ', @scores ), "\n";
    }
  }

  store( $cases, $STORE );
}

sub try_version {
  my $version = shift;
  my @table   = ( [ $version, 'type', @classes, 'match?' ] );
  my $fails   = 0;

  my %types = ( string => $version, );

  my $num_ver = eval {
    local $SIG{__WARN__} = sub { die $_[0] };
    return $version * 1;
  };

  $types{number} = $num_ver unless $@;

  my $stash = {};
  while ( my ( $type, $value ) = each %types ) {
    for my $class ( @classes ) {
      my $st = $stash->{$class} = {};
      stash( $st, $class, 'qv', $value );
      my $obj = stash( $st, $class, 'new', $value );
      print Dumper( $obj );
      if ( defined $obj ) {
        for my $method ( @method ) {
          stash( $st, $obj, $method, undef );
        }
      }
    }

    for my $method ( qw( qv new ), @method ) {
      my @row = ( $method, $type );
      my %diff = ();
      for my $class ( @classes ) {
        my $got = $stash->{$class}->{$method};
        my $vv
         = $got->{e}         ? $got->{e}
         : defined $got->{v} ? $got->{v}
         :                     '(undef)';
        $diff{$vv}++;
        push @row, $vv;
      }
      my $failed = keys( %diff ) > 1;
      push @row, $failed ? 'NO' : 'YES';
      push @table, \@row;
      $fails++ if $failed;
    }
  }

  return ( \@table, $fails );
}

sub show_table {
  my ( $table, $max ) = @_;

  my @w = ();
  for my $row ( @$table ) {
    for my $col ( 0 .. @$row - 1 ) {
      my $width = length( $row->[$col] );
      $width = $max if $width > $max;
      $w[$col] = $width if !defined $w[$col] || $width > $w[$col];
    }
  }

  my $fmt = join( ' | ', map { "%-${_}s" } @w );
  my $div = sprintf( $fmt, map { '-' x $_ } @w );
  my $bar = '=' x length( $div );

  print "$bar\n";

  for my $row ( @$table ) {
    printf( "$fmt\n", @$row );
    if ( $div ) {
      print "$div\n";
      $div = undef;
    }
  }

  print "$bar\n\n";

}

sub stash {
  my ( $stash, $obj, $method, $arg ) = @_;
  my $got = try( $obj, $method, $arg );
  $stash->{$method} = $got;
  return $got->{v};
}

sub try {
  my ( $obj, $method, $arg ) = @_;
  my $result;

  local $SIG{__WARN__} = sub { die $_[0] };
  if ( $method eq 'qv' ) {
    no strict 'refs';
    my $call = "${obj}::${method}";
    $result = eval { &$call( $arg ) };
  }
  else {
    $result = eval { $obj->$method( defined $arg ? ( $arg ) : () ) };
  }
  ( my $err = $@ ) =~ s/\s+at\s+\S+\s+line\s+\d+.*$//ms;
  return { v => $result, e => $err, };
}
