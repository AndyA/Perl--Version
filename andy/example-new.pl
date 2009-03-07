#!/usr/bin/perl

use strict;
use warnings;
use lib qw(lib);
use Perl::Version;

my @version = (
  '1.3.0',    'v1.03.00',     '1.10.03', '2.00.00',
  '1.2',      'v1.2.3.4.5.6', 'v1.2',    'Revision: 3.0',
  '1.001001', '1.001_001',    '3.0.4_001',
);

for my $v ( @version ) {
  my $version = Perl::Version->new( $v );
  $version->inc_version;
  print "$version\n";
}

# 1.3.0
# v1.03.00
# 1.10.03
# 2.00.00
# 1.2
# v1.2.3.4.5.6
# v1.2
# Revision: 3.0
# 1.001001
# 1.001_001
# 3.0.4_001
