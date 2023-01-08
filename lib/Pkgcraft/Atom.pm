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
      my $self = bless {_ptr => $ptr}, $class;
      return $self;
    }
    else {
      die "invalid CPV: $str";
    }
  }

  $ffi->attach(pkgcraft_atom_category => ['atom_t'] => 'opaque');

  sub category {
    my $self = shift;
    my $ptr  = pkgcraft_atom_category($self->{_ptr});
    my $str  = $ffi->cast('opaque' => 'string', $ptr);
    pkgcraft_str_free($ptr);
    return $str;
  }

  $ffi->attach(pkgcraft_atom_package => ['atom_t'] => 'opaque');

  sub package {
    my $self = shift;
    my $ptr  = pkgcraft_atom_package($self->{_ptr});
    my $str  = $ffi->cast('opaque' => 'string', $ptr);
    pkgcraft_str_free($ptr);
    return $str;
  }

  $ffi->attach(pkgcraft_atom_free => ['atom_t']);

  sub DESTROY {
    my $self = shift;
    pkgcraft_atom_free($self->{_ptr});
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
      my $self = bless {_ptr => $ptr}, $class;
      return $self;
    }
    else {
      die "invalid atom: $str";
    }
  }

  $ffi->attach(pkgcraft_atom_slot => ['atom_t'] => 'opaque');

  sub slot {
    my $self = shift;
    my $ptr  = pkgcraft_atom_slot($self->{_ptr});
    my $str  = $ffi->cast('opaque' => 'string', $ptr);
    pkgcraft_str_free($ptr);
    return $str;
  }

  $ffi->attach(pkgcraft_atom_subslot => ['atom_t'] => 'opaque');

  sub subslot {
    my $self = shift;
    my $ptr  = pkgcraft_atom_subslot($self->{_ptr});
    my $str  = $ffi->cast('opaque' => 'string', $ptr);
    pkgcraft_str_free($ptr);
    return $str;
  }
}
