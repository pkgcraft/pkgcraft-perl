use v5.30;
use strict;
use warnings;

require _pkgcraft_c;

package Pkgcraft::Cpv {
  use Pkgcraft::Atom::Version;

  sub new {
    my ($class, $str) = @_;
    my $ptr = C::pkgcraft_cpv_new($str);
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

  sub category {
    my ($self) = @_;
    return C::pkgcraft_atom_category($self->{_ptr});
  }

  sub package {
    my ($self) = @_;
    return C::pkgcraft_atom_package($self->{_ptr});
  }

  sub version {
    my ($self) = @_;
    my $ptr = C::pkgcraft_atom_version($self->{_ptr});
    return Pkgcraft::Atom::Version->_from_ptr($ptr);
  }

  sub revision {
    my ($self) = @_;
    return C::pkgcraft_atom_revision($self->{_ptr});
  }

  sub cpn {
    my ($self) = @_;
    return C::pkgcraft_atom_cpn($self->{_ptr});
  }

  use overload
    fallback => 1,
    '<=>' => sub {
      if ($_[0]->isa("Pkgcraft::Cpv") && $_[1]->isa("Pkgcraft::Cpv")) {
        return C::pkgcraft_atom_cmp($_[0]->{_ptr}, $_[1]->{_ptr});
      }
      die "Invalid types for comparison!";
    },
    'cmp' => sub { "$_[0]" cmp "$_[1]"; },
    '""' => 'stringify';

  sub stringify {
    my ($self) = @_;
    return C::pkgcraft_atom_str($self->{_ptr});
  }

  sub DESTROY {
    my ($self) = @_;
    if (not($self->{ref})) {
      C::pkgcraft_atom_free($self->{_ptr});
    }
  }
}

package Pkgcraft::Atom {
  use Pkgcraft::Eapi;
  our @ISA = 'Pkgcraft::Cpv';

  use constant {BLOCKER_STRONG => 0, BLOCKER_WEAK => 1};
  use constant {SLOT_OPERATOR_EQUAL => 0, SLOT_OPERATOR_STAR => 1};

  sub new {
    my ($class, $str, $eapi) = @_;

    my $eapi_ptr = undef;
    if (defined $eapi) {
      if ($eapi->isa("Pkgcraft::Eapi")) {
        $eapi_ptr = $eapi->{_ptr};
      } else {
        $eapi_ptr = EAPIS($eapi)->{_ptr} or die "unknown EAPI: $eapi";
      }
    }

    my $ptr = C::pkgcraft_atom_new($str, $eapi_ptr);
    if (defined $ptr) {
      return bless {_ptr => $ptr, ref => 0}, $class;
    }
    die "invalid atom: $str";
  }

  sub blocker {
    my ($self) = @_;
    my $blocker = C::pkgcraft_atom_blocker($self->{_ptr});
    if ($blocker >= 0) {
      return $blocker;
    }
    return;
  }

  sub slot {
    my ($self) = @_;
    return C::pkgcraft_atom_slot($self->{_ptr});
  }

  sub subslot {
    my ($self) = @_;
    return C::pkgcraft_atom_subslot($self->{_ptr});
  }

  sub slot_op {
    my ($self) = @_;
    my $slot_op = C::pkgcraft_atom_slot_op($self->{_ptr});
    if ($slot_op >= 0) {
      return $slot_op;
    }
    return;
  }

  sub use {
    my ($self, $length) = @_, 0;
    my $use = C::pkgcraft_atom_use_deps($self->{_ptr}, \$length);
    return C::string_array($use, $length);
  }

  sub repo {
    my ($self) = @_;
    return C::pkgcraft_atom_repo($self->{_ptr});
  }

  sub cpv {
    my ($self) = @_;
    return C::pkgcraft_atom_cpv($self->{_ptr});
  }
}

1;
