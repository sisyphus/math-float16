use strict;
use warnings;
use Math::Float16 qw(:all);

use Test::More;

my $pinf = Math::Float16->new(2) ** 16;
cmp_ok((is_f16_inf($pinf)), '==', 1, "\$pinf is +Inf");

my $ninf = -$pinf;
cmp_ok((is_f16_inf($ninf)), '==', -1, "\$ninf is -Inf");

cmp_ok( (is_f16_inf(Math::Float16->new(2) ** 15)),    '==', 0, " (2 ** 15) is finite");
cmp_ok( (is_f16_inf(-(Math::Float16->new(2) ** 15))), '==', 0, "-(2 ** 15) is finite");

my $bf_max = Math::Float16->new(0);
for(5..15) { $bf_max += 2 ** $_ }
#print $bf_max;
cmp_ok($bf_max, '==', $Math::Float16::f16_NORM_MAX, "max Math::Float16 value is NORM_MAX");

# Needs correcting:
cmp_ok( (is_f16_inf($bf_max + (2 ** 4))), '==', 1, "specified value is +Inf");
cmp_ok( (is_f16_inf($bf_max + (2 ** 3))), '==', 0, "specified value is finite");

my $have_mpfr = 0;
eval { require Math::MPFR;};
$have_mpfr = 1 unless $@;

if($have_mpfr) {
  my $mpfr = Math::MPFR->new();
  Math::MPFR::Rmpfr_set_inf($mpfr, 1);
  cmp_ok(Math::Float16->new($mpfr),  '==', $pinf, "MPFR('Inf')  assigns correctly");
  cmp_ok(Math::Float16->new(-$mpfr), '==', $ninf, "MPFR('-Inf') assigns correctly");
}

cmp_ok(is_f16_inf(Math::Float16->new(~0)), '==', 1, "~0 is +Inf");
cmp_ok(is_f16_inf(Math::Float16->new(-(~0 >> 2))), '==', -1, "-(~0 >> 2) is -Inf");

done_testing();
