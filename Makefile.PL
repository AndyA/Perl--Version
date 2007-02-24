use strict;
use warnings;
use ExtUtils::MakeMaker;

eval 'use ExtUtils::MakeMaker::Coverage';
warn "Optional ExtUtils::MakeMaker::Coverage not available\n" if $@;

my %ARGS = (
    NAME          => 'Perl::Version',
    AUTHOR        => 'Andy Armstrong <andy@hexten.net>',
    VERSION_FROM  => 'lib/Perl/Version.pm',
    ABSTRACT_FROM => 'lib/Perl/Version.pm',
    LICENSE       => 'perl',
    PL_FILES      => {},
    PREREQ_PM     => {
        'Test::More'   => 0,
        'version'      => 0,
        'Scalar::Util' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Perl-Version-*' },
);

$ARGS{SIGN} = 1 if MM->can( 'signature_target' );

WriteMakefile( %ARGS );
