use strict;
use warnings;
use Math::Float16 qw(:all);

use Test::More;

# DENORM_MIN is 5.9605e-8

for(3e-8, 4e-8, 5e-8, 6e-8, 7e-8) {
   cmp_ok(Math::Float16->new(8e-8), '==', Math::Float16->new($_), "8e-8 == $_ (NV)");
   cmp_ok(Math::Float16->new(8e-8), '==', Math::Float16->new(Math::MPFR->new($_)), "8e-8 == $_ (MPFR from NV)");
   cmp_ok(Math::Float16->new(2e-8 ), '!=', Math::Float16->new($_), "2e-8 != $_ (NV)");
   cmp_ok(Math::Float16->new(2e-8 ), '!=', Math::Float16->new(Math::MPFR->new($_)), "2e-8 != $_ (MPFR from NV)");
}

for ('3e-8', '4e-8', '5e-8', '6e-8', '7e-8') {
   cmp_ok(Math::Float16->new(8e-8), '==', Math::Float16->new($_), "8e-8 == $_ (PV)");
   cmp_ok(Math::Float16->new(8e-8), '==', Math::Float16->new(Math::MPFR->new($_)), "8e-8 == $_ (MPFR from PV)");
   cmp_ok(Math::Float16->new(2e-8 ), '!=', Math::Float16->new($_), "2e-8 != $_ (PV)");
   cmp_ok(Math::Float16->new(2e-8 ), '!=', Math::Float16->new(Math::MPFR->new($_)), "2e-8 != $_ (MPFR from PV)");
}

cmp_ok(Math::Float16->new(4e-41), '==', 0, '4e-41 is zero');


done_testing();
