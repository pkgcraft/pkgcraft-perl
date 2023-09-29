package C;

use v5.30;
use strict;
use version;
use warnings;

use FFI::CheckLib qw(find_lib_or_die);
use FFI::Platypus;

# version requirements for pkgcraft C library
my $MIN_VERSION = version->parse('0.0.12');
my $MAX_VERSION = version->parse('0.0.12');

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
$ffi->type('opaque' => 'config_t');
$ffi->type('opaque' => 'cpv_t');
$ffi->type('opaque' => 'dep_t');
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
$ffi->attach('pkgcraft_array_free' => ['opaque', 'int']);

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

# config support
$ffi->attach('pkgcraft_config_free' => [] => 'config_t');
$ffi->attach('pkgcraft_config_new' => [] => 'config_t');
$ffi->attach('pkgcraft_config_load' => ['config_t'] => 'opaque');
$ffi->attach('pkgcraft_config_load_portage_conf' => ['config_t', 'string'] => 'opaque');

# EAPI support
$ffi->attach('pkgcraft_eapi_as_str' => ['eapi_t'] => 'c_str');
$ffi->attach('pkgcraft_eapi_cmp' => ['eapi_t', 'eapi_t'] => 'int');
$ffi->attach('pkgcraft_eapi_has' => ['eapi_t', 'string'] => 'bool');
$ffi->attach('pkgcraft_eapis' => ['int*'] => 'opaque');
$ffi->attach('pkgcraft_eapis_official' => ['int*'] => 'opaque');
$ffi->attach('pkgcraft_eapis_range' => ['string', 'int*'] => 'opaque');

# Cpv support
$ffi->attach('pkgcraft_cpv_category' => ['cpv_t'] => 'c_str');
$ffi->attach('pkgcraft_cpv_cmp' => ['cpv_t', 'cpv_t'] => 'int');
$ffi->attach('pkgcraft_cpv_cpn' => ['cpv_t'] => 'c_str');
$ffi->attach('pkgcraft_cpv_free' => ['cpv_t']);
$ffi->attach('pkgcraft_cpv_intersects' => ['cpv_t', 'cpv_t'] => 'bool');
$ffi->attach('pkgcraft_cpv_intersects_dep' => ['cpv_t', 'dep_t'] => 'bool');
$ffi->attach('pkgcraft_cpv_new' => ['string'] => 'cpv_t');
$ffi->attach('pkgcraft_cpv_p' => ['cpv_t'] => 'c_str');
$ffi->attach('pkgcraft_cpv_package' => ['cpv_t'] => 'c_str');
$ffi->attach('pkgcraft_cpv_pf' => ['cpv_t'] => 'c_str');
$ffi->attach('pkgcraft_cpv_pr' => ['cpv_t'] => 'c_str');
$ffi->attach('pkgcraft_cpv_pv' => ['cpv_t'] => 'c_str');
$ffi->attach('pkgcraft_cpv_pvr' => ['cpv_t'] => 'c_str');
$ffi->attach('pkgcraft_cpv_str' => ['cpv_t'] => 'c_str');
$ffi->attach('pkgcraft_cpv_version' => ['cpv_t'] => 'version_t');

# Dep support
$ffi->attach('pkgcraft_dep_blocker' => ['dep_t'] => 'int');
$ffi->attach('pkgcraft_dep_blocker_from_str' => ['string'] => 'int');
$ffi->attach('pkgcraft_dep_category' => ['dep_t'] => 'c_str');
$ffi->attach('pkgcraft_dep_cmp' => ['dep_t', 'dep_t'] => 'int');
$ffi->attach('pkgcraft_dep_cpn' => ['dep_t'] => 'c_str');
$ffi->attach('pkgcraft_dep_cpv' => ['dep_t'] => 'c_str');
$ffi->attach('pkgcraft_dep_free' => ['dep_t']);
$ffi->attach('pkgcraft_dep_intersects' => ['dep_t', 'dep_t'] => 'bool');
$ffi->attach('pkgcraft_dep_intersects_cpv' => ['dep_t', 'cpv_t'] => 'bool');
$ffi->attach('pkgcraft_dep_new' => ['string', 'eapi_t'] => 'dep_t');
$ffi->attach('pkgcraft_dep_package' => ['dep_t'] => 'c_str');
$ffi->attach('pkgcraft_dep_repo' => ['dep_t'] => 'c_str');
$ffi->attach('pkgcraft_dep_slot' => ['dep_t'] => 'c_str');
$ffi->attach('pkgcraft_dep_slot_op' => ['dep_t'] => 'int');
$ffi->attach('pkgcraft_dep_slot_op_from_str' => ['string'] => 'int');
$ffi->attach('pkgcraft_dep_str' => ['dep_t'] => 'c_str');
$ffi->attach('pkgcraft_dep_subslot' => ['dep_t'] => 'c_str');
$ffi->attach('pkgcraft_dep_use_deps' => ['dep_t', 'int*'] => 'opaque');
$ffi->attach('pkgcraft_dep_version' => ['dep_t'] => 'version_t');

# version support
$ffi->attach('pkgcraft_version_cmp' => ['version_t', 'version_t'] => 'int');
$ffi->attach('pkgcraft_version_free' => ['version_t']);
$ffi->attach('pkgcraft_version_intersects' => ['version_t', 'version_t'] => 'bool');
$ffi->attach('pkgcraft_version_new' => ['string'] => 'version_t');
$ffi->attach('pkgcraft_version_revision' => ['version_t'] => 'c_str');
$ffi->attach('pkgcraft_version_str' => ['version_t'] => 'c_str');
