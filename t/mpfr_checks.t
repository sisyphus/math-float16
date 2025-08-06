use strict;
use warnings;

use Math::MPFR qw(:mpfr);
use Math::Float16 qw(:all);

use Test::More;

use constant EMIN_ORIG => Rmpfr_get_emin();
use constant EMAX_ORIG => Rmpfr_get_emax();
use constant EMIN_MOD  => f16_EMIN;
use constant EMAX_MOD  => f16_EMAX;

if($Math::MPFR::VERSION < 4.44) {
  warn "\n Aborting this test script:\n",
       " This test script needs Math-MPFR-4.44 but we have only version $Math::MPFR::VERSION\n",
       " If Math-MPFR-4.44 is not yet on CPAN, install the devel version from the github repo\n at https://github.com/sisyphus/math-mpfr\n";
       is(1, 1);
       done_testing();
       exit 0;
}

cmp_ok(Rmpfr_get_emin(), '!=', Math::Float16::_XS_get_emin(), "perl and xs have different values for mpfr_get_emin()");
cmp_ok(Rmpfr_get_emax(), '!=', Math::Float16::_XS_get_emax(), "perl and xs have different values for mpfr_get_emax()");

cmp_ok(Math::Float16::_XS_get_emin(), '==', f16_EMIN, "xs sets mpfr_get_emin() to expected value");
cmp_ok(Math::Float16::_XS_get_emax(), '==', f16_EMAX,"xs sets mpfr_get_emax() to expected value");
SET_EMIN_EMAX();
cmp_ok(Math::Float16::_XS_get_emin(), '==', f16_EMIN, "xs mpfr_get_emin() still set to expected value");
cmp_ok(Math::Float16::_XS_get_emax(), '==', f16_EMAX,"xs mpfr_get_emax() still set to expected value");
RESET_EMIN_EMAX();
cmp_ok(Math::Float16::_XS_get_emin(), '==', f16_EMIN, "xs mpfr_get_emin() still correct");
cmp_ok(Math::Float16::_XS_get_emax(), '==', f16_EMAX,"xs mpfr_get_emax() still correct");

Rmpfr_set_default_prec(f16_MANTBITS);

my $f16_rop = Math::Float16->new();
my $mpfr_rop = Math::MPFR->new();

my @p = (  (2 ** (f16_EMIN -1)),
           (2 ** f16_EMIN) + (2 ** (f16_EMIN + 2)),
           "$Math::Float16::f16_NORM_MIN",
           "$Math::Float16::f16_NORM_MAX",
           "$Math::Float16::f16_DENORM_MIN",
           "$Math::Float16::f16_DENORM_MAX",
            '2.2', '3.2', '5.2', '27.2',
        );

for my $v(@p) {
  my $f16_1 = Math::Float16->new($v);
  Rmpfr_set_FLOAT16($mpfr_rop, $f16_1, MPFR_RNDN);
  SET_EMIN_EMAX();
  my $inex = Rmpfr_sqrt($mpfr_rop, $mpfr_rop, MPFR_RNDN);
  Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
  RESET_EMIN_EMAX();
  Rmpfr_get_FLOAT16($f16_rop, $mpfr_rop, MPFR_RNDN);
  cmp_ok($f16_rop, '==', sqrt($f16_1), "sqrt($v): Math::MPFR & Math::Float16 concur");
}

my $mpfr1 = Math::MPFR->new();
my $mpfr2 = Math::MPFR->new();
my $flt_rop = Math::Float16->new();

for my $v1(@p) {
  my $flt_1 = Math::Float16->new($v1);
  Math::MPFR::Rmpfr_set_float16($mpfr1, $flt_1, 0);
  for my $v2(@p) {
    my $flt_2 = Math::Float16->new($v2);
    Math::MPFR::Rmpfr_set_FLOAT16($mpfr2, $flt_2, 0);
    SET_EMIN_EMAX();
    my $inex = Math::MPFR::Rmpfr_fmod($mpfr_rop, $mpfr1, $mpfr2, 0);
    Math::MPFR::Rmpfr_subnormalize($mpfr_rop, $inex, 0);
    RESET_EMIN_EMAX();
    Math::MPFR::Rmpfr_get_FLOAT16($flt_rop, $mpfr_rop, 0);
    cmp_ok($flt_rop, '==', $flt_1 % $flt_2, "fmod($v1, $v2): Math::MPFR & Math::Float16 concur");
  }
}

for my $v(@p) {
  my $f16_1 = Math::Float16->new($v);
  Rmpfr_set_FLOAT16($mpfr_rop, $f16_1, MPFR_RNDN);
  SET_EMIN_EMAX();
  my $inex = Rmpfr_sqr($mpfr_rop, $mpfr_rop, MPFR_RNDN);
  Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
  RESET_EMIN_EMAX();
  Rmpfr_get_FLOAT16($f16_rop, $mpfr_rop, MPFR_RNDN);
  cmp_ok($f16_rop, '==', $f16_1 ** 2, "$v ** 2: Math::MPFR & Math::Float16 concur");
}

for my $v(@p) {
  my $f16_1 = Math::Float16->new($v);
  Rmpfr_set_FLOAT16($mpfr_rop, $f16_1, MPFR_RNDN);
  Rmpfr_log($mpfr_rop, $mpfr_rop, MPFR_RNDN);
  Rmpfr_get_FLOAT16($f16_rop, $mpfr_rop, MPFR_RNDN);
  cmp_ok($f16_rop, '==', log($f16_1), "log($v): Math::MPFR & Math::Float16 concur");
}

for my $v(@p) {
  my $f16_1 = Math::Float16->new($v);
  Rmpfr_set_FLOAT16($mpfr_rop, $f16_1, MPFR_RNDN);
  Rmpfr_exp($mpfr_rop, $mpfr_rop, MPFR_RNDN);
  Rmpfr_get_FLOAT16($f16_rop, $mpfr_rop, MPFR_RNDN);
  cmp_ok($f16_rop, '==', exp($f16_1), "exp($v): Math::MPFR & Math::Float16 concur");
}

my @powers = ('0.1', '0.2', '0.3', '0.4', '0.6', '0.7', '0.8', '0.9');

for my $p(@powers) {
  my $pow = Math::MPFR->new($p);
  for my $v(@p) {
    my $f16_1 = Math::Float16->new($v);
    Rmpfr_set_FLOAT16($mpfr_rop, $f16_1, MPFR_RNDN);
    SET_EMIN_EMAX();
    my $inex = Rmpfr_pow($mpfr_rop, $mpfr_rop, $pow, MPFR_RNDN);
    Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
    Rmpfr_get_FLOAT16($f16_rop, $mpfr_rop, MPFR_RNDN);
    cmp_ok($f16_rop, '==', $f16_1 ** "$pow", "$v ** '$pow': Math::MPFR & Math::Float16 concur");
  }
}

for my $p(@powers) {
  my $pow = Math::MPFR->new($p);
  for my $v(@p) {
    my $f16_1 = Math::Float16->new($v);
    Rmpfr_set_FLOAT16($mpfr_rop, $f16_1, MPFR_RNDN);
    SET_EMIN_EMAX();
    my $inex = Rmpfr_mul($mpfr_rop, $mpfr_rop, $pow, MPFR_RNDN);
    Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
    RESET_EMIN_EMAX();
    Rmpfr_get_FLOAT16($f16_rop, $mpfr_rop, MPFR_RNDN);
    cmp_ok($f16_rop, '==', $f16_1 * "$pow", "'$v * $pow': Math::MPFR & Math::Float16 concur");
  }
}

for my $p(@powers) {
  my $pow = Math::MPFR->new($p);
  for my $v(@p) {
    my $f16_1 = Math::Float16->new($v);
    Rmpfr_set_FLOAT16($mpfr_rop, $f16_1, MPFR_RNDN);
    SET_EMIN_EMAX();
    my $inex = Rmpfr_div($mpfr_rop, $mpfr_rop, $pow, MPFR_RNDN);
    Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
    RESET_EMIN_EMAX();
    Rmpfr_get_FLOAT16($f16_rop, $mpfr_rop, MPFR_RNDN);
    cmp_ok($f16_rop, '==', $f16_1 / "$pow", "$v / '$pow': Math::MPFR & Math::Float16 concur");
  }
}

for my $p(@powers) {
  my $pow = Math::MPFR->new($p);
  for my $v(@p) {
    my $f16_1 = Math::Float16->new($v);
    Rmpfr_set_FLOAT16($mpfr_rop, $f16_1, MPFR_RNDN);
    SET_EMIN_EMAX();
    my $inex = Rmpfr_add($mpfr_rop, $mpfr_rop, $pow, MPFR_RNDN);
    Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
    RESET_EMIN_EMAX();
    Rmpfr_get_FLOAT16($f16_rop, $mpfr_rop, MPFR_RNDN);
    cmp_ok($f16_rop, '==', $f16_1 + "$pow", "$v + '$pow': Math::MPFR & Math::Float16 concur");
  }
}

for my $p(@powers) {
  my $pow = Math::MPFR->new($p);
  for my $v(@p) {
    my $f16_1 = Math::Float16->new($v);
    Rmpfr_set_FLOAT16($mpfr_rop, $f16_1, MPFR_RNDN);
    SET_EMIN_EMAX();
    my $inex = Rmpfr_sub($mpfr_rop, $mpfr_rop, $pow, MPFR_RNDN);
    Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
    RESET_EMIN_EMAX();
    Rmpfr_get_FLOAT16($f16_rop, $mpfr_rop, MPFR_RNDN);
    cmp_ok($f16_rop, '==', $f16_1 - "$pow", "$v - '$pow': Math::MPFR & Math::Float16 concur");
  }
}

#my $f1 = Math::Float16->new('5.9605e-8');
#my $f2 = Math::Float16->new('3.999e-1');
#warn "DIV: ", $f1 / $f2, "\n"; # 1.7881e-7
#print "$_\n" for @p;

done_testing();

sub SET_EMIN_EMAX {
  Rmpfr_set_emin(EMIN_MOD);
  Rmpfr_set_emax(EMAX_MOD);
}

sub RESET_EMIN_EMAX {
  Rmpfr_set_emin(EMIN_ORIG);
  Rmpfr_set_emax(EMAX_ORIG);
}



__END__
