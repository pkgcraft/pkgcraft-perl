package Pkgcraft::Atom::Version;

use Pkgcraft;

$ffi->mangler(sub {
  my($name) = @_;
  "pkgcraft_version_$name";
});
