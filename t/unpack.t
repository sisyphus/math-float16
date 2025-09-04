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



done_testing();
