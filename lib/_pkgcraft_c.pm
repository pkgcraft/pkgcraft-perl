package C;

use v5.30;
use strict;
use version;
use warnings;

use FFI::CheckLib qw(find_lib_or_die);
use FFI::Platypus;

# version requirements for pkgcraft C library
my $MIN_VERSION = version->parse('0.0.6');
my $MAX_VERSION = version->parse('0.0.6');

my $ffi = FFI::Platypus->new(api => 2);
$ffi->lib(find_lib_or_die(
  lib => 'pkgcraft',
  libpath => 'pkgcraft/lib',
  verify => sub {
    my ($name, $libpath) = @_;

    my $ffi = FFI::Platypus->new;
    $ffi->lib($libpath);

    my $f = $ffi->function('pkgcraft_lib_version' => [] => 'string');
    my $ver = version->parse($f->call());

    # verify supported version for pkgcraft C library
    return ($ver >= $MIN_VERSION and $ver <= $MAX_VERSION);
  },
));

# types
$ffi->type('opaque' => 'pkgdep_t');
$ffi->type('opaque' => 'eapi_t');
$ffi->type('opaque' => 'version_t');

# string support
$ffi->attach_cast('cast_string', 'opaque', 'string');
$ffi->attach('pkgcraft_str_free' => ['opaque']);
$ffi->custom_type(
  'c_str' => {
    native_type => 'opaque',
    native_to_perl => sub {
      my ($ptr) = @_;
      my $str = cast_string($ptr);
      pkgcraft_str_free($ptr);
      return $str;
    }
  }
);

# array support
$ffi->attach_cast('cast_array', 'opaque', 'opaque[]');
$ffi->attach('pkgcraft_str_array_free' => ['opaque', 'int']);

sub string_array {
  my ($ptr, $length) = @_;
  if (defined $ptr) {
    my $arr = cast_array($ptr);
    my @a;
    foreach my $elem (0 .. $length - 1) {
      push @a, cast_string($arr->[$elem]);
    }
    pkgcraft_str_array_free($ptr, $length);
    return \@a;
  }
  return;
}

# EAPI support
$ffi->attach('pkgcraft_eapi_as_str' => ['eapi_t'] => 'c_str');
$ffi->attach('pkgcraft_eapi_cmp' => ['eapi_t', 'eapi_t'] => 'int');
$ffi->attach('pkgcraft_eapi_has' => ['eapi_t', 'string'] => 'bool');
$ffi->attach('pkgcraft_eapis' => ['int*'] => 'opaque');
$ffi->attach('pkgcraft_eapis_free' => ['opaque', 'int']);
$ffi->attach('pkgcraft_eapis_official' => ['int*'] => 'opaque');
$ffi->attach('pkgcraft_eapis_range' => ['string', 'int*'] => 'opaque');

# pkgdep support
$ffi->attach('pkgcraft_pkgdep_blocker' => ['pkgdep_t'] => 'int');
$ffi->attach('pkgcraft_pkgdep_blocker_from_str' => ['string'] => 'int');
$ffi->attach('pkgcraft_pkgdep_category' => ['pkgdep_t'] => 'c_str');
$ffi->attach('pkgcraft_pkgdep_cmp' => ['pkgdep_t', 'pkgdep_t'] => 'int');
$ffi->attach('pkgcraft_pkgdep_cpn' => ['pkgdep_t'] => 'c_str');
$ffi->attach('pkgcraft_pkgdep_cpv' => ['pkgdep_t'] => 'c_str');
$ffi->attach('pkgcraft_pkgdep_free' => ['pkgdep_t']);
$ffi->attach('pkgcraft_pkgdep_intersects' => ['pkgdep_t', 'pkgdep_t'] => 'bool');
$ffi->attach('pkgcraft_pkgdep_new' => ['string', 'eapi_t'] => 'pkgdep_t');
$ffi->attach('pkgcraft_pkgdep_package' => ['pkgdep_t'] => 'c_str');
$ffi->attach('pkgcraft_pkgdep_repo' => ['pkgdep_t'] => 'c_str');
$ffi->attach('pkgcraft_pkgdep_slot' => ['pkgdep_t'] => 'c_str');
$ffi->attach('pkgcraft_pkgdep_slot_op' => ['pkgdep_t'] => 'int');
$ffi->attach('pkgcraft_pkgdep_slot_op_from_str' => ['string'] => 'int');
$ffi->attach('pkgcraft_pkgdep_str' => ['pkgdep_t'] => 'c_str');
$ffi->attach('pkgcraft_pkgdep_subslot' => ['pkgdep_t'] => 'c_str');
$ffi->attach('pkgcraft_pkgdep_use_deps' => ['pkgdep_t', 'int*'] => 'opaque');
$ffi->attach('pkgcraft_pkgdep_version' => ['pkgdep_t'] => 'version_t');
$ffi->attach('pkgcraft_cpv_new' => ['string'] => 'pkgdep_t');

# version support
$ffi->attach('pkgcraft_version_cmp' => ['version_t', 'version_t'] => 'int');
$ffi->attach('pkgcraft_version_free' => ['version_t']);
$ffi->attach('pkgcraft_version_intersects' => ['version_t', 'version_t'] => 'bool');
$ffi->attach('pkgcraft_version_new' => ['string'] => 'version_t');
$ffi->attach('pkgcraft_version_revision' => ['version_t'] => 'c_str');
$ffi->attach('pkgcraft_version_str' => ['version_t'] => 'c_str');
$ffi->attach('pkgcraft_version_str_with_op' => ['version_t'] => 'c_str');
$ffi->attach('pkgcraft_version_with_op' => ['string'] => 'version_t');
