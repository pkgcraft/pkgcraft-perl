use Pkgcraft;
use Pkgcraft::Eapi;

$ffi->type('opaque' => 'atom_t');

package Pkgcraft::Cpv {
  use Pkgcraft;
  use Pkgcraft::Atom::Version;

  $ffi->attach('pkgcraft_cpv_new' => ['string'] => 'atom_t');

  sub new {
    my ($class, $str) = @_;
    my $ptr = pkgcraft_cpv_new($str);
    if (defined $ptr) {
      return bless {_ptr => $ptr, ref => 0}, $class;
    }
    die "invalid CPV: $str";
  }

  sub _from_ptr {
    my ($class, $ptr) = @_;
    if (defined $ptr) {
      return bless {_ptr => $ptr, ref => 1}, $class;
    }
    return;
  }

  $ffi->attach('pkgcraft_atom_category' => ['atom_t'] => 'c_str');

  sub category {
    my ($self) = @_;
    return pkgcraft_atom_category($self->{_ptr});
  }

  $ffi->attach('pkgcraft_atom_package' => ['atom_t'] => 'c_str');

  sub package {
    my ($self) = @_;
    return pkgcraft_atom_package($self->{_ptr});
  }

  $ffi->attach('pkgcraft_atom_version' => ['atom_t'] => 'version_t');

  sub version {
    my ($self) = @_;
    my $ptr = pkgcraft_atom_version($self->{_ptr});
    return Pkgcraft::Atom::Version->_from_ptr($ptr);
  }

  $ffi->attach('pkgcraft_atom_revision' => ['atom_t'] => 'c_str');

  sub revision {
    my ($self) = @_;
    return pkgcraft_atom_revision($self->{_ptr});
  }

  $ffi->attach('pkgcraft_atom_cpn' => ['atom_t'] => 'c_str');

  sub cpn {
    my ($self) = @_;
    return pkgcraft_atom_cpn($self->{_ptr});
  }

  $ffi->attach('pkgcraft_atom_cmp' => ['atom_t', 'atom_t'] => 'int');

  use overload
    fallback => 1,
    '<=>'    => sub {
      if ($_[0]->isa("Pkgcraft::Atom") && $_[1]->isa("Pkgcraft::Atom")) {
        return pkgcraft_atom_cmp($_[0]->{_ptr}, $_[1]->{_ptr});
      }
      die "Invalid types for comparison!";
    },
    'cmp' => sub { "$_[0]" cmp "$_[1]"; },
    '""'  => 'stringify';

  $ffi->attach('pkgcraft_atom_str' => ['atom_t'] => 'c_str');

  sub stringify {
    my ($self) = @_;
    return pkgcraft_atom_str($self->{_ptr});
  }

  $ffi->attach('pkgcraft_atom_free' => ['atom_t']);

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

  use constant {BLOCKER_STRONG      => 0, BLOCKER_WEAK       => 1};
  use constant {SLOT_OPERATOR_EQUAL => 0, SLOT_OPERATOR_STAR => 1};

  $ffi->attach('pkgcraft_atom_new' => ['string', 'Eapi'] => 'atom_t');

  sub new {
    my ($class, $str) = @_;
    my $ptr = pkgcraft_atom_new($str);
    if (defined $ptr) {
      return bless {_ptr => $ptr, ref => 0}, $class;
    }
    die "invalid atom: $str";
  }

  $ffi->attach('pkgcraft_atom_blocker' => ['atom_t'] => 'int');

  sub blocker {
    my ($self) = @_;
    my $blocker = pkgcraft_atom_blocker($self->{_ptr});
    if ($blocker >= 0) {
      return $blocker;
    }
    return;
  }

  $ffi->attach('pkgcraft_atom_slot' => ['atom_t'] => 'c_str');

  sub slot {
    my ($self) = @_;
    return pkgcraft_atom_slot($self->{_ptr});
  }

  $ffi->attach('pkgcraft_atom_subslot' => ['atom_t'] => 'c_str');

  sub subslot {
    my ($self) = @_;
    return pkgcraft_atom_subslot($self->{_ptr});
  }

  $ffi->attach('pkgcraft_atom_slot_op' => ['atom_t'] => 'int');

  sub slot_op {
    my ($self) = @_;
    my $slot_op = pkgcraft_atom_slot_op($self->{_ptr});
    if ($slot_op >= 0) {
      return $slot_op;
    }
    return;
  }

  $ffi->attach('pkgcraft_atom_use_deps' => ['atom_t', 'int*'] => 'opaque');

  sub use {
    my ($self, $length) = @_, 0;
    my $use = pkgcraft_atom_use_deps($self->{_ptr}, \$length);
    return string_array($use, $length);
  }

  $ffi->attach('pkgcraft_atom_repo' => ['atom_t'] => 'c_str');

  sub repo {
    my ($self) = @_;
    return pkgcraft_atom_repo($self->{_ptr});
  }

  $ffi->attach('pkgcraft_atom_cpv' => ['atom_t'] => 'c_str');

  sub cpv {
    my ($self) = @_;
    return pkgcraft_atom_cpv($self->{_ptr});
  }
}
