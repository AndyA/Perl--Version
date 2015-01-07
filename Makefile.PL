use strict;
use warnings;

eval 'use ExtUtils::MakeMaker::Coverage';

my $github    = 'https://github.com/briandfoy/';
my $main_file = 'lib/Perl/Version.pm';

my %ARGS = (
  license( 'perl' ),
  NAME          => 'Perl::Version',
  AUTHOR        => 'Andy Armstrong <andy@hexten.net>',
  VERSION_FROM  => 'lib/Perl/Version.pm',
  ABSTRACT_FROM => 'lib/Perl/Version.pm',
  PL_FILES      => {},
  PREREQ_PM     => {
  	'Carp'               => 0,
    'Test::More'         => 0,
    'Scalar::Util'       => 0,
    'Getopt::Long'       => '2.34',
    'Pod::Usage'         => '1.3',
    'File::Slurp::Tiny'  => 0,
    'Data::Dumper'       => 0,
  },
  EXE_FILES => ['examples/perl-reversion'],
  dist      => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
  clean => { FILES => 'Perl-Version-*' },
  META_MERGE => {
    'meta-spec' => { version => 2 },
    resources   => {
      repository => {
        type => 'git',
        url  => 'https://github.com/briandfoy/Perl--Version.git',
        web  => 'https://github.com/briandfoy/Perl--Version',
      },
    },
  },
);

WriteMakefile( %ARGS );

sub license {
  my $lic = shift;
  local $^W = 0;    # Silence warning about non-numeric version
  return
   unless $ExtUtils::MakeMaker::VERSION >= '6.31';
  return ( LICENSE => $lic );
}

sub arguments { \%WriteMakefile }

do_it() unless caller;
sub do_it {
	require File::Spec;
	my $MM ='ExtUtils::MakeMaker';
	my $MM_version =
		eval{ "$MM " . $WriteMakefile{'CONFIGURE_REQUIRES'}{'ExtUtils::MakeMaker'} }
			//
		"$MM 6.64";
	eval "use $MM_version";
	eval "use Test::Manifest 1.21" 
		if -e File::Spec->catfile( qw(t test_manifest) );
	WriteMakefile( %WriteMakefile );
	}


no warnings;
__PACKAGE__;
