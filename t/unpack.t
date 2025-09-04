use strict;
use warnings;
use Math::Float16 qw(:all);

my $have_mpfr = 0;
eval { require Math::MPFR;};
$have_mpfr = 1 unless $@;

use Test::More;
cmp_ok(unpack_f16_hex($Math::Float16::f16_DENORM_MIN), 'eq', '0001', "DENORM_MIN unpacks correctly");
cmp_ok(unpack_f16_hex($Math::Float16::f16_DENORM_MAX), 'eq', '03FF', "DENORM_MAX unpacks correctly");
cmp_ok(unpack_f16_hex($Math::Float16::f16_NORM_MIN),   'eq', '0400', "NORM_MIN unpacks correctly");
cmp_ok(unpack_f16_hex($Math::Float16::f16_NORM_MAX),   'eq', '7BFF', "NORM_MAX unpacks correctly");
cmp_ok(unpack_f16_hex(sqrt(Math::Float16->new(2))),     'eq', '3DA8', "sqrt 2 unpacks correctly");
cmp_ok(unpack_f16_hex(Math::Float16->new('6e-8')),     'eq', '0001', "'6e-8' unpacks correctly");
cmp_ok(unpack_f16_hex(Math::Float16->new(Math::MPFR->new('6e-8'))), 'eq', '0001', "MPFR('6e-8') unpacks correctly") if $have_mpfr;

cmp_ok(unpack_f16_hex(-$Math::Float16::f16_DENORM_MIN), 'eq', '8001', "-DENORM_MIN unpacks correctly");
cmp_ok(unpack_f16_hex(-$Math::Float16::f16_DENORM_MAX), 'eq', '83FF', "-DENORM_MAX unpacks correctly");
cmp_ok(unpack_f16_hex(-$Math::Float16::f16_NORM_MIN),   'eq', '8400', "-NORM_MIN unpacks correctly");
cmp_ok(unpack_f16_hex(-$Math::Float16::f16_NORM_MAX),   'eq', 'FBFF', "-NORM_MAX unpacks correctly");
cmp_ok(unpack_f16_hex(-(sqrt(Math::Float16->new(2)))),   'eq', 'BDA8', "-(sqrt 2) unpacks correctly");
cmp_ok(unpack_f16_hex(Math::Float16->new('-6e-8')),     'eq', '8001', "'-6e-8' unpacks correctly");
cmp_ok(unpack_f16_hex(Math::Float16->new(Math::MPFR->new('-6e-8'))), 'eq', '8001', "MPFR('-6e-8') unpacks correctly") if $have_mpfr;

if($have_mpfr) {
  my $inc = Math::Float16->new('0');
  my $dec = Math::Float16->new('-0');

  my $mpfr_inc   = Math::MPFR::Rmpfr_init2(16);
  my $mpfr_dec   = Math::MPFR::Rmpfr_init2(16);
  my $mpfr_store = Math::MPFR::Rmpfr_init2(16);
  Math::MPFR::Rmpfr_set_zero($mpfr_store, 1); # Set to 0.
  my $rnd = 0; # Round to nearest, ties to even.

  cmp_ok(unpack_f16_hex($inc), 'eq', '0000', " 0 unpacks to 0000");
  cmp_ok(unpack_f16_hex($dec), 'eq', '8000', "-0 unpacks to 8000");

  for(1..31744) {
    f16_nextabove($inc);
    f16_nextbelow($dec);
    my $unpack_inc = unpack_f16_hex($inc);
    my $unpack_dec = unpack_f16_hex($dec);

    cmp_ok(length($unpack_inc), '==', 4, "length($unpack_inc) == 4");
    cmp_ok(length($unpack_dec), '==', 4, "length($unpack_inc) == 4");

    Math::MPFR::Rmpfr_strtofr($mpfr_inc, $unpack_inc, 16, $rnd);
    cmp_ok($mpfr_inc - $mpfr_store, '==', 1, "inc has been incremented to $unpack_inc");
    Math::MPFR::Rmpfr_strtofr($mpfr_dec, $unpack_dec, 16, $rnd);
    cmp_ok($mpfr_dec - $mpfr_inc, '==', 0x8000, "dec has been decremented to $unpack_dec");

    Math::MPFR::Rmpfr_set($mpfr_store, $mpfr_inc, $rnd);
  }
  cmp_ok(is_f16_inf($inc), '==', 1, "values have reached infinity");
}

done_testing();
