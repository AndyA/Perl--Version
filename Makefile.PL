use strict;
use warnings;
use ExtUtils::MakeMaker;

eval 'use ExtUtils::MakeMaker::Coverage';

my %EXE = (
  'perl-reversion' => {
    PREREQ_PM => {
      'Getopt::Long' => '2.34',
      'Pod::Usage'   => '1.3',
      'File::Slurp'  => '9999.12',
    },
    EXE_FILES => ['examples/perl-reversion'],
  }
);

my %ARGS = (
  NAME          => 'Perl::Version',
  AUTHOR        => 'Andy Armstrong <andy@hexten.net>',
  VERSION_FROM  => 'lib/Perl/Version.pm',
  ABSTRACT_FROM => 'lib/Perl/Version.pm',
  LICENSE       => 'perl',
  PL_FILES      => {},
  PREREQ_PM     => {
    'Test::More'   => 0,
    'Scalar::Util' => 0,
  },
  dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
  clean => { FILES    => 'Perl-Version-*' },
);

$ARGS{SIGN} = 1 if MM->can( 'signature_target' );

while ( my ( $exe, $spec ) = each %EXE ) {
  my $yn = prompt( "Install $exe script?", "N" );
  if ( $yn =~ /^y/i ) {
    while ( my ( $key, $val ) = each %$spec ) {
      if ( ref $val eq 'HASH' ) {
        $ARGS{$key} = { %{ $ARGS{$key} || {} }, %$val };
      }
      elsif ( ref $val eq 'ARRAY' ) {
        push @{ $ARGS{$key} }, @$val;
      }
      else {
        die "Can't merge $key: value not handled\n";
      }
    }
  }
}

WriteMakefile( %ARGS );
