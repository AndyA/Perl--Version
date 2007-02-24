#!/usr/bin/perl

use strict;
use warnings;
use Carp;
use lib qw(lib);

use Perl::Version;

# Init from string
my $version = Perl::Version->new( '1.2.3' );

# Stringification preserves original format
print "$version\n";                 # prints '1.2.3'

# Normalised
print $version->normal, "\n";       # prints 'v1.2.3'

# Numified
print $version->numify, "\n";       # prints '1.002003'

# Explicitly stringified
print $version->stringify, "\n";    # prints '1.2.3'

# Increment the subversion (the third field)
$version->inc_subversion;

# Stringification returns the updated version formatted
# as the original was
print "$version\n";                 # prints '1.2.4'

# Normalised
print $version->normal, "\n";       # prints 'v1.2.4'

# Numified
print $version->numify, "\n";       # prints '1.002004'

# Refer to subversion field by position ( zero based )
$version->increment( 2 );

print "$version\n";                 # prints '1.2.5'

# Increment the version (second field) which sets all
# fields to the right of it to zero.
$version->inc_version;

print "$version\n";                 # prints '1.3.0'

# Increment the revision (main version number)
$version->inc_revision;

print "$version\n";                 # prints '2.0.0'

# Increment the alpha number
$version->inc_alpha;

print "$version\n";                 # prints '2.0.0_001'
