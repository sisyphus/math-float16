use strict;
use warnings;
package Math::Float16;

use constant f16_EMIN     => -23;
use constant f16_EMAX     =>  16;
use constant f16_MANTBITS =>  11;


use overload
'+'  => \&oload_add,
'-'  => \&oload_sub,
'*'  => \&oload_mul,
'/'  => \&oload_div,
'%'  => \&oload_fmod,
'**' => \&oload_pow,

'=='  => \&oload_equiv,
'!='  => \&oload_not_equiv,
'>'   => \&oload_gt,
'>='  => \&oload_gte,
'<'   => \&oload_lt,
'<='  => \&oload_lte,
'<=>' => \&oload_spaceship,

'abs'  => \&oload_abs,
'""'   => \&oload_interp,
 # The above overload subs are in Float16.pm.
 # The below overload subs are in Float16.xs.
'sqrt' => \&_oload_sqrt,
'exp'  => \&_oload_exp,
'log'  => \&_oload_log,
'int'  => \&_oload_int,
'!'    => \&_oload_not,
'bool' => \&_oload_bool,
;

require Exporter;
*import = \&Exporter::import;
require DynaLoader;

our $VERSION = '0.01';
Math::Float16->DynaLoader::bootstrap($VERSION);

sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking

if(_MPFR_VERSION() < 262912 || !_buildopt_float16_p()) {
  warn "Aborting: The underlying mpfr library (", _MPFR_VERSION_STRING(), ") does not support the _Float16 type";
  exit 0;
}

my @tagged = qw( f16_to_NV f16_to_MPFR
                 is_f16_nan is_f16_inf is_f16_zero f16_set_nan f16_set_inf f16_set_zero
                 f16_set
                 f16_nextabove f16_nextbelow
                 unpack_f16_hex
                 f16_EMIN f16_EMAX f16_MANTBITS
               );

@Math::Float16::EXPORT = ();
@Math::Float16::EXPORT_OK = @tagged;
%Math::Float16::EXPORT_TAGS = (all => \@tagged);


%Math::Float16::handler = (1 => sub {print "OK: 1\n"},
               2  => sub {return _fromIV(shift)},
               4  => sub {return _fromPV(shift)},
               3  => sub {return _fromNV(shift)},
               5  => sub {return _fromMPFR(shift)},
               6  => sub {return _fromGMPf(shift)},
               7  => sub {return _fromGMPq(shift)},

               21 => sub {return _fromFloat16(shift)},
               );

$Math::Float16::f16_DENORM_MIN = Math::Float16->new(2) ** (f16_EMIN - 1);                  # 5.9605e-8
$Math::Float16::f16_DENORM_MAX = Math::Float16->new(_get_denorm_max());                    # 6.0976e-5
$Math::Float16::f16_NORM_MIN   = Math::Float16->new(2) ** (f16_EMIN + (f16_MANTBITS - 2)); # 6.1035e-5
$Math::Float16::f16_NORM_MAX   = Math::Float16->new(_get_norm_max());                      # 6.5504e4

sub new {
   shift if (@_ > 0 && !ref($_[0]) && _itsa($_[0]) == 4 && $_[0] eq "Math::Float16");
   if(!@_) {
     my $ret = _fromIV(0);
     f16_set_nan($ret);
     return $ret;
   }
   die "Too many args given to new()" if @_ > 1;
   my $itsa = _itsa($_[0]);
   if($itsa) {
     my $coderef = $Math::Float16::handler{$itsa};
     return $coderef->($_[0]);
   }
   die "Unrecognized 1st argument passed to new() function";
}

sub f16_set {
   die "f16_set expects to receive precisely 2 arguments" if @_ != 2;
   my $itsa = _itsa($_[1]);
   if($itsa == 21) { _f16_set(@_) }
   else {
     my $coderef = $Math::Float16::handler{$itsa};
     _f16_set( $_[0], $coderef->($_[1]));
   }
}

sub oload_add {
   my $itsa = _itsa($_[1]);
   return _oload_add(@_) if $itsa == 21;
   if($itsa < 5) {
     my $coderef = $Math::Float16::handler{$itsa};
     return _oload_add($_[0], $coderef->($_[1]), 0);
   }
   die "Unrecognized 2nd argument passed to oload_add() function";
}

sub oload_mul {
   my $itsa = _itsa($_[1]);
   return _oload_mul(@_) if $itsa == 21;
   if($itsa < 5) {
     my $coderef = $Math::Float16::handler{$itsa};
     return _oload_mul($_[0], $coderef->($_[1]), 0);
   }
   die "Unrecognized 2nd argument passed to oload_mul() function";
}

sub oload_sub {
   my $itsa = _itsa($_[1]);
   return _oload_sub(@_) if $itsa == 21;
   if($itsa < 5) {
     my $coderef = $Math::Float16::handler{$itsa};
     return _oload_sub($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_sub() function";
}

sub oload_div {
   my $itsa = _itsa($_[1]);
   return _oload_div(@_) if $itsa == 21;
   if($itsa < 5) {
     my $coderef = $Math::Float16::handler{$itsa};
     return _oload_div($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_div() function";
}

sub oload_pow {
   my $itsa = _itsa($_[1]);
   return _oload_pow(@_) if $itsa == 21;
   if($itsa < 5) {
     my $coderef = $Math::Float16::handler{$itsa};
     return _oload_pow($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_pow() function";
}

sub oload_fmod {
   my $itsa = _itsa($_[1]);
   return _oload_fmod(@_) if $itsa == 21;
   if($itsa < 5) {
     my $coderef = $Math::Float16::handler{$itsa};
     return _oload_fmod($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_fmod() function";
}

sub oload_abs {
  return $_[0] * -1 if $_[0] < 0;
  return $_[0];
}

sub oload_equiv {
   my $itsa = _itsa($_[1]);
   if($itsa == 21 || $itsa < 5) {
     my $coderef = $Math::Float16::handler{$itsa};
     return _oload_equiv($_[0], $coderef->($_[1]), 0);
   }
   die "Unrecognized 2nd argument passed to oload_equiv() function";
}

sub oload_not_equiv {
   my $itsa = _itsa($_[1]);
   if($itsa == 21 || $itsa < 5) {
     my $coderef = $Math::Float16::handler{$itsa};
     return _oload_not_equiv($_[0], $coderef->($_[1]), 0);
   }
   die "Unrecognized 2nd argument passed to oload_not_equiv() function";
}

sub oload_gt {
   my $itsa = _itsa($_[1]);
   if($itsa == 21 || $itsa < 5) {
     my $coderef = $Math::Float16::handler{$itsa};
     return _oload_gt($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_gt() function";
}

sub oload_gte {
   my $itsa = _itsa($_[1]);
   if($itsa == 21 || $itsa < 5) {
     my $coderef = $Math::Float16::handler{$itsa};
     return _oload_gte($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_gte() function";
}

sub oload_lt {
   my $itsa = _itsa($_[1]);
   if($itsa == 21 || $itsa < 5) {
     my $coderef = $Math::Float16::handler{$itsa};
     return _oload_lt($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_lt() function";
}

sub oload_lte {
   my $itsa = _itsa($_[1]);
   if($itsa == 21 || $itsa < 5) {
     my $coderef = $Math::Float16::handler{$itsa};
     return _oload_lte($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_lte() function";
}

sub oload_spaceship {
   my $itsa = _itsa($_[1]);
   if($itsa == 21 || $itsa < 5) {
     my $coderef = $Math::Float16::handler{$itsa};
     return _oload_spaceship($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_spaceship() function";
}

sub oload_interp {
   my $ret = float16_get_str(f16_to_MPFR($_[0]), 10, 0, 0); # MPFR_RNDN
   $ret =~ s/\@//g;
   return $ret;
}

sub float16_get_str {
    my ($mantissa, $exponent) = _deref2($_[0], $_[1], $_[2], $_[3]);

    if($mantissa =~ s/@//g) { return $mantissa }
    if($mantissa =~ /\-/ && $mantissa !~ /[^0,\-]/) {return '-0'}
    if($mantissa !~ /[^0]/ ) {return '0'}

    my $len = substr($mantissa, 0, 1) eq '-' ? 2 : 1;

    if(!$_[2]) {
      while(length($mantissa) > $len && substr($mantissa, -1, 1) eq '0') {
           substr($mantissa, -1, 1, '');
      }
    }

    $exponent--;

    my $sep = $_[1] <= 10 ? 'e' : '@';

    if(length($mantissa) == $len) {
      if($exponent) {return $mantissa . $sep . $exponent}
      return $mantissa;
    }

    substr($mantissa, $len, 0, '.');
    if($exponent) {return $mantissa . $sep . $exponent}
    return $mantissa;
}

sub f16_nextabove {
  if(is_f16_zero($_[0])) {
    f16_set($_[0], $Math::Float16::f16_DENORM_MIN);
  }
  elsif(is_f16_inf($_[0]) == -1) {
    f16_set($_[0], -$Math::Float16::f16_NORM_MAX);
  }
  elsif($_[0] < $Math::Float16::f16_NORM_MIN && $_[0] >= -$Math::Float16::f16_NORM_MIN ) {
    $_[0] += $Math::Float16::f16_DENORM_MIN;
    f16_set_zero($_[0], -1) if is_f16_zero($_[0]);
  }
  else {
    _f16_nextabove($_[0]);
  }
}

sub f16_nextbelow {
  if(is_f16_zero($_[0])) {
    f16_set($_[0], -$Math::Float16::f16_DENORM_MIN);
  }
  elsif(is_f16_inf($_[0]) == 1) {
    f16_set($_[0], $Math::Float16::f16_NORM_MAX);
  }
  elsif($_[0] <= $Math::Float16::f16_NORM_MIN && $_[0] > -$Math::Float16::f16_NORM_MIN ) {
    $_[0] -= $Math::Float16::f16_DENORM_MIN;
  }
  else {
    _f16_nextbelow($_[0]);
  }
}

sub unpack_f16_hex {
  die "Math::Float16::unpack_f16_hex() accepts only a Math::Float16 object as its argument"
    unless ref($_[0]) eq "Math::Float16";
  my @ret = _unpack_f16_hex($_[0]);
  return join('', @ret);
}

sub _get_norm_max {
  my $ret = 0;
  for my $p(1 .. f16_MANTBITS) { $ret += 2 ** (f16_EMAX - $p) }
  return $ret;
}

sub _get_denorm_max {
  my $ret = 0;
  my $max = -(f16_EMIN - 1);
  my $min = $max - (f16_MANTBITS - 2);
  for my $p($min .. $max) { $ret += 2 ** -$p }
  return $ret;
}

1;

__END__
