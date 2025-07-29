use strict;
use warnings;
use Math::Float16 qw(:all);

use Test::More;

cmp_ok(Math::Float16::_XS_get_emin(), '==', f16_EMIN, "emin set correctly");
cmp_ok(Math::Float16::_XS_get_emax(), '==', f16_EMAX, "emax set correctly");

my $nan = Math::Float16->new();
cmp_ok( (is_f16_nan($nan)), '==', 1, "new obj is NaN");

f16_nextabove($nan);
cmp_ok( (is_f16_nan($nan)), '==', 1, "next above NaN is NaN");

f16_nextbelow($nan);
cmp_ok( (is_f16_nan($nan)), '==', 1, "next below NaN is NaN");

my $pinf = Math::Float16->new();

f16_set_inf($pinf, 1);
cmp_ok( (is_f16_inf($pinf)), '==', 1, "+inf is inf");

f16_nextbelow($pinf);
cmp_ok( (is_f16_inf($pinf)), '==', 0, "next below +inf is not inf");
cmp_ok( $pinf, '==', $Math::Float16::f16_NORM_MAX , "next below +inf is NORM_MAX");

f16_nextabove($pinf);
cmp_ok( (is_f16_inf($pinf)), '==', 1, "next above NORM_MAX is inf");

my $pmin = $Math::Float16::f16_DENORM_MIN;
cmp_ok($pmin, '==', '5.9605e-8', "DENORM_MIN is 5.9605e-8 ");

f16_nextbelow($pmin);
cmp_ok($pmin, '==', 0, "next below DENORM_MIN is zero");
cmp_ok( (is_f16_zero($pmin)), '==', 1, "next below DENORM_MIN is unsigned zero");

f16_nextabove($pmin);
cmp_ok($pmin, '==', $Math::Float16::f16_DENORM_MIN, "next above zero is DENORM_MIN");

my $ninf = -$pinf;
cmp_ok( (is_f16_inf($ninf)), '==', -1, "inf is -inf");

f16_nextabove($ninf);
cmp_ok( (is_f16_inf($ninf)), '==', 0, "next above -inf is not inf");
cmp_ok( $ninf, '==', -$Math::Float16::f16_NORM_MAX , "next above -inf is -NORM_MAX");

f16_nextbelow($ninf);
cmp_ok( (is_f16_inf($ninf)), '==', -1, "next below -NORM_MAX is -inf");

my $nmin = -$pmin;

f16_nextabove($nmin);
cmp_ok($nmin, '==', 0, "next above -min is zero");
cmp_ok( (is_f16_zero($nmin)), '==', -1, "next above -min is -0");

f16_nextbelow($nmin);
cmp_ok($nmin, '==', -$Math::Float16::f16_DENORM_MIN, "next below zero is -DENORM_MIN");

my $zero =Math::Float16->new(0);

#for(127 .. 133) { $max_subnormal += 2 ** -$_ }
my $max_subnormal = $Math::Float16::f16_DENORM_MAX;
cmp_ok($max_subnormal, '==', '6.0976e-5', "DENORM_MAX is 6.0976e-5");

f16_nextabove($max_subnormal);
cmp_ok($max_subnormal, '==', $Math::Float16::f16_NORM_MIN, "next above max subnormal is NORM_MIN");

f16_nextbelow($max_subnormal);
cmp_ok($max_subnormal, '==', $Math::Float16::f16_DENORM_MAX, "next below NORM_MIN is DENORM_MAX");

my $neg_normal_min = -$Math::Float16::f16_NORM_MIN;
f16_nextabove($neg_normal_min);
cmp_ok($neg_normal_min, '==', -$Math::Float16::f16_DENORM_MAX, "next above -NORM_MIN is -DENORM_MAX");

my $min        = Math::Float16->new("$Math::Float16::f16_DENORM_MIN");
my $cumulative = Math::Float16->new("$Math::Float16::f16_DENORM_MIN");

my @p = ($cumulative);
my $n = 2 ** (f16_MANTBITS - 1);
$n--;
for(1..$n) {
   $cumulative += $min;
   push (@p, $cumulative);
}

my $check = Math::Float16->new(0);

for(0..$n) {
  f16_nextabove($check);
  cmp_ok($check, '==', $p[$_], "$_: as expected ($p[$_])");
}

f16_nextbelow($check);
cmp_ok($check, '==', $Math::Float16::f16_DENORM_MAX, "DENORM_MAX as expected");

f16_nextbelow($check);
cmp_ok($check, '==', $Math::Float16::f16_DENORM_MAX - $Math::Float16::f16_DENORM_MIN, "DENORM_MAX - DENORM_MIN as expected");

f16_set_zero($check, 1);

for(0..$n) {
  f16_nextbelow($check);
  cmp_ok($check, '==', -$p[$_], "$_: as expected (-$p[$_])");
}

f16_nextabove($check);
cmp_ok($check, '==', -$Math::Float16::f16_DENORM_MAX, "-DENORM_MAX as expected");

f16_nextabove($check);
cmp_ok($check, '==', -$Math::Float16::f16_DENORM_MAX + $Math::Float16::f16_DENORM_MIN, "-DENORM_MAX + DENORM_MIN as expected");

done_testing();
