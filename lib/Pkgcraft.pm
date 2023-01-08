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
our @EXPORT = qw($ffi c_str pkgcraft_str_free _c_str_to_string);

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

$ffi->attach(pkgcraft_str_free => ['opaque']);
$ffi->custom_type('c_str' => {
  native_type => 'opaque',
  native_to_perl => sub {
    my ($ptr) = @_;
    my $str = $ffi->cast('opaque' => 'string', $ptr);
    pkgcraft_str_free($ptr);
    return $str;
  }
});
