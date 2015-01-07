use strict;
use warnings;

eval 'use ExtUtils::MakeMaker::Coverage';

my $github    = 'https://github.com/briandfoy/Perl--Version';
my $main_file = 'lib/Perl/Version.pm';

my %WriteMakefile = (
	LICENSE       => 'perl',
	NAME          => 'Perl::Version',
	AUTHOR        => 'Andy Armstrong <andy@hexten.net>',
	VERSION_FROM  => $main_file,
	ABSTRACT_FROM => $main_file,

	'CONFIGURE_REQUIRES' => {
		'ExtUtils::MakeMaker' => '6.64',
		},

	'BUILD_REQUIRES' => {
		},

	'TEST_REQUIRES' => {
		'Test::More' => '0.94',
		},

	'PREREQ_PM'     => {
		'Carp'               => 0,
		'Scalar::Util'       => 0,
		'Getopt::Long'       => '2.34',
		'Pod::Usage'         => '1.3',
		'File::Slurp::Tiny'  => 0,
		'Data::Dumper'       => 0,
		},
	
	EXE_FILES => ['examples/perl-reversion'],

	dist      => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },

	clean => { FILES => 'Perl-Version-*' },

	'META_MERGE' => {
		'meta-spec' => { version => 2 },
		resources => {
			repository => {
				type => 'git',
				url  => "$github.git",
				web  => $github,
				},
			bugtraker => {
				web    => "$github/issues",
				},
			homepage => $github,
			},
		},
);

sub arguments { \%WriteMakefile }

do_it() unless caller;
sub do_it {
	require File::Spec;
	my $MM ='ExtUtils::MakeMaker';
	my $MM_version =
		eval{ "$MM " . $WriteMakefile{'CONFIGURE_REQUIRES'}{'ExtUtils::MakeMaker'} }
			//
		"$MM 6.64";
	eval "use $MM_version" || die "Could not load $MM_version: $@";
	eval "use Test::Manifest 1.21" 
		if -e File::Spec->catfile( qw(t test_manifest) );
	WriteMakefile( %WriteMakefile );
	}


no warnings;
__PACKAGE__;
