#!/usr/bin/perl

use strict;
use warnings;
use Carp;
use lib qw(lib);
use Perl::Version qw(qv);
use version;
use Data::Dumper;
use Term::ANSIColor;

my $reference = require 't/reference.pl';

my %w = ();

for my $test ( @$reference ) {
  while ( my ( $method, $expect ) = each %$test ) {
    my $vv = ref $expect ? $expect->{v} : $expect;
    my $width = length( $vv || '' ) + 5;
    $w{$method} ||= 0;
    $w{$method} = $width if $w{$method} < $width;
  }
}

my @columns = qw( version new );
my %ww      = %w;
delete $ww{$_} for @columns;
@columns = ( @columns, sort keys %ww );

my $fmt = join( ' | ', map { "%-$w{$_}s" } @columns );
my $div = sprintf( $fmt, map { '-' x $w{$_} } @columns );
my $bar = '=' x length( $div );
my $hdr = sprintf( $fmt, @columns );
print "$bar\n$hdr\n$bar\n";

my %pos;
for my $col ( 0 .. $#columns ) {
  $pos{ $columns[$col] } = $col;
}

sub do_test {
  my ( $method, $arg, $obj ) = @_;
  my $result;
  if ( $method eq 'qv' ) {
    $result = eval { qv( $arg ) };
  }
  else {
    $result = eval { $obj->$method( $arg ) };
  }
  ( my $err = $@ ) =~ s/\s+at\s+\S+\s+line\s+\d+.*$//ms;

  return {
    v => $result,
    e => $err,
  };
}

sub record_test {
  my ( $before, $after, $expect, $method, $arg, $obj ) = @_;

  my $pos = $pos{$method};

  my $ref = $expect->{e} || $expect->{v} || '(nothing)';
  my $got = do_test( $method, $arg, $obj );
  my $act = $got->{e} || $got->{v} || '(nothing)';

  $before->[$pos] = substr $ref, 0, $w{$method};
  $after->[$pos]  = substr $act, 0, $w{$method};

  return ( $got, $ref cmp $act );
}

# Run the tests
for my $test ( @$reference ) {

  my $version = delete $test->{version};

  my @empty = ( '', ) x ( @columns - 1 );
  my @before = ( $version, @empty );
  my @after = ( '', @empty );

  my ( $got, $diff )
   = record_test( \@before, \@after, delete $test->{new},
    'new', $version, 'Perl::Version' );
  my $obj = $got->{v};

  while ( my ( $method, $expect ) = each %$test ) {
    my ( undef, $d )
     = record_test( \@before, \@after, $expect, $method, $version,
      $obj );
    $diff ||= $d;
  }

  if ( $diff ) {
    printf( "$fmt\n", @before );
    printf( "$fmt\n", @after );
    print "$div\n";
  }
}
