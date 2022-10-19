package Pkgcraft::Atom;

use Pkgcraft;

$ffi->mangler(sub {
  my($name) = @_;
  "pkgcraft_atom_$name";
});
