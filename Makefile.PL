use strict;
use warnings;
use Config;
use ExtUtils::MakeMaker;

eval{ require 5.032;};

if($@) {
  warn "\n Aborting build of Math::Float16 because:\n$@\n";
  exit 0;
}

if($Config{ptrsize} == 4) {
  warn "\n Aborting build of Math::Float16 because this is a 32-bit build of perl.\n",
       " (We might address this in the future to support 32-bit builds.)\n";
  exit 0;
}

###########################################
# Check whether  _Float16 type is recognized #
###########################################

my $have_float16 = 0;
my $mycc = $Config{cc};
#$mycc .= ' -msse2' if $Config{ptrsize} == 4;

my $out = `$mycc -o have_float16.exe -x c have_float16.in 2>&1`;
if( -e 'have_float16.exe') {
  my $size = $^O =~ /MSWin32/i ? `have_float16.exe` : `./have_float16.exe`;
  $have_float16 = 1 if $size eq '2';
}

if(!$have_float16) {
  warn "Aborting build of Math::Float16 because the  _Float16 type is not recognized by your compiler";
  exit 0;
}

unlink "./have_float16.exe"; # No longer needed - leaving it in place can cause confusion.

eval { require Math::MPFR;};

if($@) {
  warn "\n Aborting build of Math::Float16 because Math::MPFR failed to load.\n",
       " Please install latest release of Math::MPFR from CPAN, and then try again.\n",
       " See also the README file.\n";
  exit 0;
}

if($Math::MPFR::VERSION < '4.43') {
  warn "\n Aborting build of Math::Float16 because the installed version ($Math::MPFR::VERSION) is too old.\n",
       " We need at least version 4.43. See the README file.\n",
       " Please install latest release of Math::MPFR from CPAN, and then try again.\n";
  exit 0;
}

if(Math::MPFR::MPFR_VERSION() < 262912) {
  warn "\n Aborting build of Math::Float16 because Math::MPFR has been built\n",
       " against an mpfr C library that is too old.\n",
       " The library needs to be at version 4.3.0 or later. This is only ", Math::MPFR::MPFR_VERSION_STRING(), "\n",
       " See the README file.\n";
  exit 0;
}

my $build_opt = Math::MPFR::Rmpfr_buildopt_float16_p();

unless($build_opt) {
  warn "\n Aborting because the mpfr C library against which Math::MPFR has been\n",
       " built does not support the  _Float16 type.\n",
       " See the README file.\n";
  exit 0;
}

my %options = (
  NAME         => 'Math::Float16',
  AUTHOR       => 'Sisyphus (sisyphus at (@) cpan dot (.) org)',
  ABSTRACT     => "Perl interface to C's  _Float16 arithmetic",
  LICENSE      => 'perl',
  VERSION_FROM => 'Float16.pm',
  LIBS         =>  ['-lmpfr -lgmp -lquadmath'],
  clean        => { FILES => '*.exe *.txt' },
  META_MERGE   => {
    'meta-spec'  => { version => 2 },
    resources    => {
      repository   => {
        type         => 'git',
        url          => 'https://github.com/sisyphus/math-float16.git',
        web          => 'https://github.com/sisyphus/math-float16',
      },
    },
  },
);

my $prereq =  { 'Test::More' => '0.88',
                'Test::Warn' => '0.36',
                'Exporter'   => '5.58',
                'Math::MPFR' => '4.43',
              };

$options{PREREQ_PM} = $prereq;

WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
