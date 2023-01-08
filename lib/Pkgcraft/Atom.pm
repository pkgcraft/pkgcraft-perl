use Pkgcraft;
use Pkgcraft::Eapi;

$ffi->type('opaque' => 'atom_t');

package Pkgcraft::Cpv {
  use Pkgcraft;
  use Pkgcraft::Atom::Version;

  $ffi->attach(pkgcraft_cpv_new => ['string'] => 'atom_t');

  sub new {
    my ($class, $str) = @_;
    my $ptr = pkgcraft_cpv_new($str);
    if (defined $ptr) {
      return bless {_ptr => $ptr, ref => 0}, $class;
    }
    die "invalid CPV: $str";
  }

  $ffi->attach(pkgcraft_atom_category => ['atom_t'] => 'c_str');

  sub category {
    my ($self) = @_;
    return pkgcraft_atom_category($self->{_ptr});
  }

  $ffi->attach(pkgcraft_atom_package => ['atom_t'] => 'c_str');

  sub package {
    my ($self) = @_;
    return pkgcraft_atom_package($self->{_ptr});
  }

  $ffi->attach(pkgcraft_atom_version => ['atom_t'] => 'version_t');

  sub version {
    my ($self) = @_;
    my $ptr = pkgcraft_atom_version($self->{_ptr});
    return Pkgcraft::Atom::Version->_from_ptr($ptr);
  }

  $ffi->attach(pkgcraft_atom_revision => ['atom_t'] => 'c_str');

  sub revision {
    my ($self) = @_;
    return pkgcraft_atom_revision($self->{_ptr});
  }

  use overload
    fallback => 0,
    '<'      => sub { $_[0]->cmp($_[1]) == -1; },
    '<='     => sub { $_[0]->cmp($_[1]) <= 0; },
    '=='     => sub { $_[0]->cmp($_[1]) == 0; },
    '!='     => sub { $_[0]->cmp($_[1]) != 0; },
    '>='     => sub { $_[0]->cmp($_[1]) >= 0; },
    '>'      => sub { $_[0]->cmp($_[1]) == 1; },
    '""'     => 'stringify';

  $ffi->attach(pkgcraft_atom_cmp => ['atom_t', 'atom_t'] => 'int');

  sub cmp {
    my ($self, $other) = @_;
    return pkgcraft_atom_cmp($self->{_ptr}, $other->{_ptr});
  }

  $ffi->attach(pkgcraft_atom_str => ['atom_t'] => 'c_str');

  sub stringify {
    my ($self) = @_;
    return pkgcraft_atom_str($self->{_ptr});
  }

  $ffi->attach(pkgcraft_atom_free => ['atom_t']);

  sub DESTROY {
    my ($self) = @_;
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
    my ($class, $str) = @_;
    my $ptr = pkgcraft_atom_new($str);
    if (defined $ptr) {
      return bless {_ptr => $ptr, ref => 0}, $class;
    }
    die "invalid atom: $str";
  }

  $ffi->attach(pkgcraft_atom_slot => ['atom_t'] => 'c_str');

  sub slot {
    my ($self) = @_;
    return pkgcraft_atom_slot($self->{_ptr});
  }

  $ffi->attach(pkgcraft_atom_subslot => ['atom_t'] => 'c_str');

  sub subslot {
    my ($self) = @_;
    return pkgcraft_atom_subslot($self->{_ptr});
  }

  $ffi->attach(pkgcraft_atom_repo => ['atom_t'] => 'c_str');

  sub repo {
    my ($self) = @_;
    return pkgcraft_atom_repo($self->{_ptr});
  }

  $ffi->attach(pkgcraft_atom_cpv => ['atom_t'] => 'c_str');

  sub cpv {
    my ($self) = @_;
    return pkgcraft_atom_cpv($self->{_ptr});
  }
}
