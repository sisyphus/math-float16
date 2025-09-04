use strict;
use warnings;

use Math::Float16 qw(:all);

use Test::More;

eval { require Math::FakeFloat16;};

if($@) {
  warn "Skipping all tests as  Math::FakeFloat16 failed to load";
  is(1, 1);
  done_testing();
  exit 0;
}

Math::MPFR::Rmpfr_set_default_prec(f16_MANTBITS);

my @p = (  (2 ** (f16_EMIN -1)),
           (2 ** f16_EMIN) + (2 ** (f16_EMIN + 2)),
           "$Math::Float16::f16_NORM_MIN",
           "$Math::Float16::f16_NORM_MAX",
           "$Math::Float16::f16_DENORM_MIN",
           "$Math::Float16::f16_DENORM_MAX",
            '2.2', '3.2', '5.2', '27.2',
        );

for my $v(@p) {
  my $f16 =  Math::Float16->new($v);
  my $fake =  Math::FakeFloat16->new($v);
  cmp_ok("$f16", 'eq', "$fake", "$v: real and fake match");

  my $sqrt_f16 = sqrt($f16);
  my $sqrt_fake = sqrt($fake);
  cmp_ok("$sqrt_f16", 'eq', "$sqrt_fake", "sqrt $v: real and fake match");
}


for my $v1(@p) {
  my $flt_1 =  Math::Float16->new($v1);
  my $fake_1 =  Math::FakeFloat16->new($v1);
  for my $v2(@p) {
    my $flt_2 =  Math::Float16->new($v2);
    my $fake_2 =  Math::FakeFloat16->new($v2);

    my $fmod_flt_1 = $flt_1 % $flt_2;
    my $fmod_flt_2 = $flt_2 % $flt_1;

    my $fmod_fake_1 = $fake_1 % $fake_2;
    my $fmod_fake_2 = $fake_2 % $fake_1;

    cmp_ok("$fmod_flt_1", 'eq', "$fmod_fake_1", "$v1 % $v2: real and fake match");
    cmp_ok("$fmod_flt_2", 'eq', "$fmod_fake_2", "$v2 % $v1: real and fake match");



    my $pow_flt_1 = $flt_1 ** $flt_2;
    my $pow_flt_2 = $flt_2 ** $flt_1;

    my $pow_fake_1 = $fake_1 ** $fake_2;
    my $pow_fake_2 = $fake_2 ** $fake_1;

    cmp_ok("$pow_flt_1", 'eq', "$pow_fake_1", "$v1 ** $v2: real and fake match");
    cmp_ok("$pow_flt_2", 'eq', "$pow_fake_2", "$v2 ** $v1: real and fake match");


  }
}

my @powers = ('0.1', '0.2', '0.3', '0.4', '0.6', '0.7', '0.8', '0.9');

for my $p(@powers) {
  for my $v(@p) {
    my $f16_1 =  Math::Float16->new($v) ** $p;
    my $f16_2 =  Math::Float16->new($p) ** $v;
    my $fake_1 =  Math::FakeFloat16->new($v) ** $p;
    my $fake_2 =  Math::FakeFloat16->new($p) ** $v;
    cmp_ok("$f16_1", 'eq', "$fake_1", "$p ** $v: real and fake match");
    cmp_ok("$f16_2", 'eq', "$fake_2", "$p ** $v: real and fake match");
  }
}

for my $p(@powers) {
  for my $v(@p) {
    my $f16_1 =  Math::Float16->new($v) * $p;
    my $f16_2 =  Math::Float16->new($p) * $v;
    my $fake_1 =  Math::FakeFloat16->new($v) * $p;
    my $fake_2 =  Math::FakeFloat16->new($p) * $v;
    cmp_ok("$f16_1", 'eq', "$fake_1", "$p * $v: real and fake match");
    cmp_ok("$f16_2", 'eq', "$fake_2", "$p * $v: real and fake match");
    cmp_ok($f16_1, '==', $f16_2, "* (real) : commutative law holds");
    cmp_ok($fake_1, '==', $fake_2, "* (fake) : commutative law holds");
  }
}

for my $p(@powers) {
  for my $v(@p) {
    my $f16_1 =  Math::Float16->new($v) / $p;
    my $f16_2 =  Math::Float16->new($p) / $v;
    my $fake_1 =  Math::FakeFloat16->new($v) / $p;
    my $fake_2 =  Math::FakeFloat16->new($p) / $v;
    cmp_ok("$f16_1", 'eq', "$fake_1", "$p / $v: real and fake match");
    cmp_ok("$f16_2", 'eq', "$fake_2", "$p / $v: real and fake match");
  }
}

for my $p(@powers) {
  for my $v(@p) {
    my $f16_1 =  Math::Float16->new($v) + $p;
    my $f16_2 =  Math::Float16->new($p) + $v;
    my $fake_1 =  Math::FakeFloat16->new($v) + $p;
    my $fake_2 =  Math::FakeFloat16->new($p) + $v;
    cmp_ok("$f16_1", 'eq', "$fake_1", "$p + $v: real and fake match");
    cmp_ok("$f16_2", 'eq', "$fake_2", "$p + $v: real and fake match");
    cmp_ok($f16_1, '==', $f16_2, "+ (real) : commutative law holds");
    cmp_ok($fake_1, '==', $fake_2, "+ (fake) : commutative law holds");
  }
}

for my $p(@powers) {
  for my $v(@p) {
    my $f16_1 =  Math::Float16->new($v) - $p;
    my $f16_2 =  Math::Float16->new($p) - $v;
    my $fake_1 =  Math::FakeFloat16->new($v) - $p;
    my $fake_2 =  Math::FakeFloat16->new($p) - $v;
    cmp_ok("$f16_1", 'eq', "$fake_1", "$p - $v: real and fake match");
    cmp_ok("$f16_2", 'eq', "$fake_2", "$p - $v: real and fake match");
    cmp_ok($f16_1, '==', -$f16_2, "* (real) : converse relationship holds");
    cmp_ok($fake_1, '==', -$fake_2, "* (fake) : converse relationship holds");
  }
}

Math::MPFR::Rmpfr_set_default_prec($Math::MPFR::NV_properties{bits});

for my $man(1 ..15 ) {
  for my $exp(26 .. 41) {
    my $s = "${man}e-${exp}";
    my $f16_1 =  Math::Float16->new($s);
    my $fake_1 =  Math::FakeFloat16->new($s);
    cmp_ok("$f16_1", 'eq', "$fake_1", "$s: agreement between real and fake");
    my $nv = $s + 0;
    my $f16_2 =  Math::Float16->new($nv);
    my $fake_2 =  Math::FakeFloat16->new($nv);
    cmp_ok("$f16_2", 'eq', "$fake_2", "$nv: agreement between real and fake");
    cmp_ok($fake_1, '==', $fake_2, "$nv: both  Math::FakeFloat16 objects are equivalent");
  }
}

my($have_gmpf, $have_gmpq) = (0, 0);

eval { require Math::GMPf;};
if($@) { warn "skipping Math::GMPf tests\n" }
else { $have_gmpf = 1 }

eval { require Math::GMPq;};
if($@) { warn "skipping Math::GMPq tests\n" }
else { $have_gmpq = 1 }

my @corners = ('0b0.1000000000000001p-133', '-0b0.1000000000000001p-133', '0b0.1p-133', '-0b0.1p-133',
              '4.5919149377459931e-41', '-4.5919149377459931e-41', 4.5919149377459931e-41, -4.5919149377459931e-41,
               Math::MPFR->new('0b0.1000000000000001p-133'), Math::MPFR->new('-0b0.1000000000000001p-133'),
               Math::MPFR->new('0b0.1p-133'), Math::MPFR->new('-0b0.1p-133'),
               Math::MPFR->new(4.5919149377459931e-41), Math::MPFR->new(-4.5919149377459931e-41)
              );

if($have_gmpf) { push @corners, Math::GMPf->new(4.5919149377459931e-41), Math::GMPf->new(-4.5919149377459931e-41),
                                Math::GMPf->new(4.5e-41), Math::GMPf->new(-4.5e-41) }
if($have_gmpq) { push @corners, Math::GMPq->new(4.5919149377459931e-41), Math::GMPq->new(-4.5919149377459931e-41),
                                Math::GMPq->new(4.5e-41), Math::GMPq->new(-4.5e-41) }

for my $c(@corners) {
  my $f16 =  Math::Float16->new($c);
  my $fake =  Math::FakeFloat16->new($c);
  cmp_ok("$f16", 'eq', "$fake", "$c: fake & real agree");
}

@corners = ('0b0.11111111p+128',       '-0b0.11111111p+128', 3.3895313892515355e38, -3.3895313892515355e38,
           '0b0.11111111011111p+128', '-0b0.11111111011111p+128', 3.3959698373561187e38, -3.3959698373561187e38,
           Math::MPFR->new(3.3895313892515355e38), Math::MPFR->new(-3.3895313892515355e38),
           Math::MPFR->new(3.3959698373561187e38), Math::MPFR->new(-3.3959698373561187e38), );

if($have_gmpf) { push @corners, Math::GMPf->new(3.3895313892515355e38), Math::GMPf->new(-3.3895313892515355e38),
                Math::GMPf->new(3.3959698373561187e38), Math::GMPf->new(-3.3959698373561187e38) }

if($have_gmpq) { push @corners, Math::GMPq->new(3.3895313892515355e38), Math::GMPq->new(-3.3895313892515355e38),
                Math::GMPq->new(3.3959698373561187e38), Math::GMPq->new(-3.3959698373561187e38) }

for my $s(@corners) {
  my $f16 =  Math::Float16->new($s);
  my $fake =  Math::FakeFloat16->new($s);
  cmp_ok("$f16", 'eq', "$fake", "$s: fake & real agree");
}

@corners = ('0b0.01111111111111p+128', '-0b0.01111111111111p+128', 1.7012041427303509e38, -1.7012041427303509e38,
           Math::MPFR->new(1.7012041427303509e38), Math::MPFR->new(-1.7012041427303509e38));

if($have_gmpf) { push @corners, Math::GMPf->new(1.7012041427303509e38), Math::GMPf->new(-1.7012041427303509e38) }
if($have_gmpq) { push @corners, Math::GMPq->new(1.7012041427303509e38), Math::GMPq->new(-1.7012041427303509e38) }


for my $s (@corners) {
  my $f16 =  Math::Float16->new($s);
  my $fake =  Math::FakeFloat16->new($s);
  cmp_ok("$f16", 'eq', "$fake", "$s: fake & real agree");
}

@corners = ('0b0.111111111p+128',  '-0b0.111111111p+128', 3.3961775292304601e38, -3.3961775292304601e38,
            Math::MPFR->new(3.3961775292304601e38), Math::MPFR->new(-3.3961775292304601e38));

if($have_gmpf) { push @corners, Math::GMPf->new(3.3961775292304601e38), Math::GMPf->new(-3.3961775292304601e38) }
if($have_gmpq) { push @corners, Math::GMPq->new(3.3961775292304601e38), Math::GMPq->new(-3.3961775292304601e38) }


for my $s (@corners) {
  my $f16 =  Math::Float16->new($s);
  my $fake =  Math::FakeFloat16->new($s);
  cmp_ok("$f16", 'eq', "$fake", "$s: fake & real agree");
}

@corners = ('0b0.1p+129', '0b0.1111111111111111p+129', '0b0.1p+130', '0b0.1111111111111111p+130',
            '0b0.1p+250', '0b0.1111111111111111p+250',
            3.4028236692093846e38, 6.8055434924815986e38, 6.8056473384187693e38, 1.3611086984963197e39,
            9.0462569716653278e74, 1.8092237873476784e75,
            Math::MPFR->new(3.4028236692093846e38), Math::MPFR->new(6.8055434924815986e38),
            Math::MPFR->new(6.8056473384187693e38), Math::MPFR->new(1.3611086984963197e39),
            Math::MPFR->new(9.0462569716653278e74), Math::MPFR->new(1.8092237873476784e75)
           );

if($have_gmpf) { push @corners, Math::GMPf->new(3.4028236692093846e38), Math::GMPf->new(6.8055434924815986e38),
                                Math::GMPf->new(6.8056473384187693e38), Math::GMPf->new(1.3611086984963197e39),
                                Math::GMPf->new(9.0462569716653278e74), Math::GMPf->new(1.8092237873476784e75) }

if($have_gmpq) { push @corners, Math::GMPq->new(3.4028236692093846e38), Math::GMPq->new(6.8055434924815986e38),
                                Math::GMPq->new(6.8056473384187693e38), Math::GMPq->new(1.3611086984963197e39),
                                Math::GMPq->new(9.0462569716653278e74), Math::GMPq->new(1.8092237873476784e75) }

for my $s (@corners) {
  my $f16 =  Math::Float16->new($s);
  my $fake =  Math::FakeFloat16->new($s);
  cmp_ok("$f16", 'eq', "$fake", "$s: fake & real agree");
}

#################################################
#################################################

@corners = ('-0b0.1p+129', '-0b0.1111111111111111p+129', '-0b0.1p+130', '-0b0.1111111111111111p+130',
            '-0b0.1p+250', '-0b0.1111111111111111p+250',
            -3.4028236692093846e38, -6.8055434924815986e38, -6.8056473384187693e38, -1.3611086984963197e39,
            -9.0462569716653278e74, -1.8092237873476784e75,
            Math::MPFR->new(-3.4028236692093846e38), Math::MPFR->new(-6.8055434924815986e38),
            Math::MPFR->new(-6.8056473384187693e38), Math::MPFR->new(-1.3611086984963197e39),
            Math::MPFR->new(-9.0462569716653278e74), Math::MPFR->new(-1.8092237873476784e75)
           );

if($have_gmpf) { push @corners, Math::GMPf->new(-3.4028236692093846e38), Math::GMPf->new(-6.8055434924815986e38),
                                Math::GMPf->new(-6.8056473384187693e38), Math::GMPf->new(-1.3611086984963197e39),
                                Math::GMPf->new(-9.0462569716653278e74), Math::GMPf->new(-1.8092237873476784e75) }

if($have_gmpq) { push @corners, Math::GMPq->new(-3.4028236692093846e38), Math::GMPq->new(-6.8055434924815986e38),
                                Math::GMPq->new(-6.8056473384187693e38), Math::GMPq->new(-1.3611086984963197e39),
                                Math::GMPq->new(-9.0462569716653278e74), Math::GMPq->new(-1.8092237873476784e75) }

for my $s (@corners) {
  my $f16 =  Math::Float16->new($s);
  my $fake =  Math::FakeFloat16->new($s);
  cmp_ok("$f16", 'eq', "$fake", "$s: fake & real agree");
}

for my $iv(1, -1, 1234567, -1234567, ~0, ~0 >> 1, -(~0 >> 1), ~0 >> 2, -(~0 >> 2)) {
  my $f16 =  Math::Float16->new($iv);
  my $fake =  Math::FakeFloat16->new($iv);
  cmp_ok("$f16", 'eq', "$fake", "IV $iv: fake & new agree");
}

done_testing();

__END__

