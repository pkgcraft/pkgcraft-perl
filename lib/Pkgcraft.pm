package Pkgcraft;

use v5.30;
use strict;
use version;
use warnings;

use FFI::CheckLib qw(find_lib_or_die);
use FFI::Platypus;

our $VERSION = '0.01';

use Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw($ffi c_str string_array);

our $ffi = FFI::Platypus->new(api => 2);
$ffi->lib(find_lib_or_die(
  lib     => 'pkgcraft',
  libpath => 'pkgcraft/lib',
  verify  => sub {
    my ($name, $libpath) = @_;

    my $ffi = FFI::Platypus->new;
    $ffi->lib($libpath);

    my $f          = $ffi->function('pkgcraft_lib_version', [] => 'string');
    my $ver        = version->parse($f->call());
    my $MINVERSION = version->parse('0.0.4');
    my $MAXVERSION = version->parse('0.0.4');

    return ($ver >= $MINVERSION and $ver <= $MAXVERSION);
  },
));

$ffi->attach_cast("cast_string", 'opaque', 'string');
$ffi->attach(pkgcraft_str_free => ['opaque']);

$ffi->custom_type(
  'c_str' => {
    native_type    => 'opaque',
    native_to_perl => sub {
      my ($ptr) = @_;
      my $str = cast_string($ptr);
      pkgcraft_str_free($ptr);
      return $str;
    }
  }
);

$ffi->attach_cast("cast_array", 'opaque', 'opaque[]');
$ffi->attach(pkgcraft_str_array_free => ['opaque', 'int']);

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
