use Pkgcraft;
use Pkgcraft::Eapi;

$ffi->type('opaque' => 'atom_t');

package Pkgcraft::Cpv {
  use Pkgcraft;

  $ffi->attach(pkgcraft_cpv_new => ['string'] => 'atom_t');

  sub new {
    my $class = shift;
    my $str   = shift;
    my $ptr   = pkgcraft_cpv_new($str);
    if (defined $ptr) {
      return bless {_ptr => $ptr, ref => 0}, $class;
    }
    else {
      die "invalid CPV: $str";
    }
  }

  $ffi->attach(pkgcraft_atom_category => ['atom_t'] => 'c_str');

  sub category {
    my $self = shift;
    return _c_str_to_string(pkgcraft_atom_category($self->{_ptr}));
  }

  $ffi->attach(pkgcraft_atom_package => ['atom_t'] => 'c_str');

  sub package {
    my $self = shift;
    return _c_str_to_string(pkgcraft_atom_package($self->{_ptr}));
  }

  use overload
    fallback => 0,
    '""'     => 'stringify';

  $ffi->attach(pkgcraft_atom_str => ['atom_t'] => 'c_str');

  sub stringify {
    my $self = shift;
    return _c_str_to_string(pkgcraft_atom_str($self->{_ptr}));
  }

  $ffi->attach(pkgcraft_atom_free => ['atom_t']);

  sub DESTROY {
    my $self = shift;
    if (not($self->{ref})) {
      pkgcraft_atom_free($self->{_ptr});
    }
  }
}

package Pkgcraft::Atom {
  use Pkgcraft;
  our @ISA = qw(Pkgcraft::Cpv);

  $ffi->attach(pkgcraft_atom_new => ['string', 'Eapi'] => 'atom_t');

  sub new {
    my $class = shift;
    my $str   = shift;
    my $ptr   = pkgcraft_atom_new($str);
    if (defined $ptr) {
      return bless {_ptr => $ptr, ref => 0}, $class;
    }
    else {
      die "invalid atom: $str";
    }
  }

  $ffi->attach(pkgcraft_atom_slot => ['atom_t'] => 'c_str');

  sub slot {
    my $self = shift;
    return _c_str_to_string(pkgcraft_atom_slot($self->{_ptr}));
  }

  $ffi->attach(pkgcraft_atom_subslot => ['atom_t'] => 'c_str');

  sub subslot {
    my $self = shift;
    return _c_str_to_string(pkgcraft_atom_subslot($self->{_ptr}));
  }
}
