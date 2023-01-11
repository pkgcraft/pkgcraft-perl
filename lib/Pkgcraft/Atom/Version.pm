use v5.30;
use strict;
use warnings;

require _pkgcraft_c;

package Pkgcraft::Atom::Version {

  sub new {
    my ($class, $str) = @_;
    my $ptr = C::pkgcraft_version_new($str);
    if (defined $ptr) {
      return bless {_ptr => $ptr, ref => 0}, $class;
    }
    die "invalid version: $str";
  }

  sub _from_ptr {
    my ($class, $ptr) = @_;
    if (defined $ptr) {
      return bless {_ptr => $ptr, ref => 1}, $class;
    }
    return;
  }

  sub revision {
    my ($self) = @_;
    return C::pkgcraft_version_revision($self->{_ptr});
  }

  use overload
    fallback => 1,
    '<=>' => sub {
      if ($_[0]->isa("Pkgcraft::Atom::Version") && $_[1]->isa("Pkgcraft::Atom::Version"))
      {
        return C::pkgcraft_version_cmp($_[0]->{_ptr}, $_[1]->{_ptr});
      }
      die "Invalid types for comparison!";
    },
    'cmp' => sub { "$_[0]" cmp "$_[1]"; },
    '""' => 'stringify';

  sub stringify {
    my ($self) = @_;
    return C::pkgcraft_version_str($self->{_ptr});
  }

  sub DESTROY {
    my ($self) = @_;
    if (not($self->{ref})) {
      C::pkgcraft_version_free($self->{_ptr});
    }
  }
}

package Pkgcraft::Atom::VersionWithOp {
  use parent 'Pkgcraft::Atom::Version';

  sub new {
    my ($class, $str) = @_;
    my $ptr = C::pkgcraft_version_with_op($str);
    if (defined $ptr) {
      return bless {_ptr => $ptr, ref => 0}, $class;
    }
    die "invalid version: $str";
  }
}

1;
