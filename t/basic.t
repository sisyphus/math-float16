use strict;
use warnings;

use Math::Float16 qw(:all);

use Test::More;

cmp_ok($Math::Float16::VERSION, '==', '0.01', "We have Math-Float162-0.01");


done_testing();
