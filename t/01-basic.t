#!perl

use strict;
use warnings;

use Test::More;

use Exception::StringBased (
  PermissionException => [ qw(login password) ],
  'PermissionException2',
);

my $e = PermissionException->new(qw(login));
print Dumper($e); use Data::Dumper;

# PermissionException->raise(qw(login));
# PermissionException->raise(qw(flag1 flag2) );

# Type->Exception::raise(@args);

print " plop : " . $e->flag::login() . "\n";
print " plop : " . $e->flag::password() . "\n";

my $e2 = PermissionException2->new();
print Dumper($e2); use Data::Dumper;

print " plop2 : " . $e2->flag::login() . "\n";

done_testing();
