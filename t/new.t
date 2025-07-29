use strict;
use warnings;
use Math::Float16 qw(:all);

use Test::More;

my($have_gmpf, $have_gmpq) = (0, 0);

eval { require Math::GMPf };
$have_gmpf = 1 unless $@;

eval { require Math::GMPq };
$have_gmpq = 1 unless $@;

my @inputs = ('1.5', '-1.75', 2.625, Math::MPFR->new(3.875), 42);

#push(@inputs, Math::GMPf->new(5.25)) if $have_gmpf;
push(@inputs, Math::GMPq->new('3/4')) if $have_gmpq;

for my $in(@inputs) {
  cmp_ok(f16_to_NV(Math::Float16->new($in)), '==', $in, "f16_to_NV: $in ok");
  cmp_ok(f16_to_MPFR(Math::Float16->new($in)), '==', $in, "f16_to_MPFR: $in ok");

  cmp_ok(f16_to_NV(Math::Float16->new(-$in)), '==', -$in, "f16_to_NV: -$in ok");
  cmp_ok(f16_to_MPFR(Math::Float16->new(-$in)), '==', -$in, "f16_to_MPFR: -$in ok");
}

if($have_gmpf) {
  # There's no overloading of '==' between Math::MPFR and Math::GMPf
  my $in = Math::GMPf->new(5.25);
  cmp_ok(f16_to_MPFR(Math::Float16->new($in)),  '==', Math::MPFR->new($in),  "f16_to_MPFR from GMPf: $in ok");
  cmp_ok(f16_to_MPFR(Math::Float16->new(-$in)), '==', Math::MPFR->new(-$in), "f16_to_MPFR from GMPf: -$in ok");
}

cmp_ok(ref(Math::Float16->new()), 'eq', 'Math::Float16', "Math::Float16->new() returns a Math::Float16 object");
cmp_ok(ref(Math::Float16::new()), 'eq', 'Math::Float16', "Math::Float16::new() returns a Math::Float16 object");


cmp_ok(is_f16_nan(Math::Float16->new()), '==', 1, "Math::Float16->new() returns NaN");
cmp_ok(is_f16_nan(Math::Float16::new()), '==', 1, "Math::Float16::new() returns NaN");

my $obj = Math::Float16->new('1.414');
cmp_ok(Math::Float16->new($obj), '==', $obj, "new(obj) == obj");
cmp_ok(Math::Float16->new($obj), '==', '1.414', "new(obj) == value of obj");

my $mpfr_obj = Math::MPFR->new();
Math::MPFR::Rmpfr_set_inf($mpfr_obj, 1);
#print "$mpfr_obj\n";
my $pinf = Math::Float16->new($mpfr_obj);
cmp_ok(is_f16_inf($pinf), '==', 1, "+Inf, as expected");

Math::MPFR::Rmpfr_set_inf($mpfr_obj, -1);
my $ninf = Math::Float16->new($mpfr_obj);
cmp_ok(is_f16_inf($ninf), '==', -1, "-Inf, as expected");

Math::MPFR::Rmpfr_set_si($mpfr_obj, -1, 0);
my $not_inf = Math::Float16->new($mpfr_obj);
cmp_ok(is_f16_inf($not_inf), '==', 0, "Not an infinity");
cmp_ok(is_f16_zero($not_inf), '==', 0, "Not a zero");

Math::MPFR::Rmpfr_set_zero($mpfr_obj, 1);
my $pzero = Math::Float16->new($mpfr_obj);
cmp_ok(is_f16_zero($pzero), '==', 1, "+0, as expected");

Math::MPFR::Rmpfr_set_zero($mpfr_obj, -1);
my $nzero = Math::Float16->new($mpfr_obj);
cmp_ok(is_f16_zero($nzero), '==', -1, "-0, as expected");

done_testing();
