use v5.30;
use strict;
use warnings;

require _pkgcraft_c;

package Pkgcraft::Revision {
  sub new {
    my $class = shift;
    my $str = shift // die "missing revision string";
    my $ptr = C::pkgcraft_revision_new($str) // die "invalid revision: $str";
    return bless {_ptr => $ptr}, $class;
  }

  sub _from_ptr {
    my ($class, $ptr) = @_;
    if (defined $ptr) {
      return bless {_ptr => $ptr}, $class;
    }
    return;
  }

  use overload
    fallback => 1,
    '<=>' => sub {
      if ($_[0]->isa("Pkgcraft::Revision") && $_[1]->isa("Pkgcraft::Revision")) {
        return C::pkgcraft_revision_cmp($_[0]->{_ptr}, $_[1]->{_ptr});
      }
      die "Invalid types for comparison!";
    },
    'cmp' => sub { "$_[0]" cmp "$_[1]"; },
    '""' => 'stringify';

  sub stringify {
    my $self = shift;
    return C::pkgcraft_revision_str($self->{_ptr});
  }

  sub DESTROY {
    my $self = shift;
    C::pkgcraft_revision_free($self->{_ptr});
  }
}

package Pkgcraft::Version {
  sub new {
    my $class = shift;
    my $str = shift // die "missing version string";
    my $ptr = C::pkgcraft_version_new($str) // die "invalid version: $str";
    return bless {_ptr => $ptr}, $class;
  }

  sub _from_ptr {
    my ($class, $ptr) = @_;
    if (defined $ptr) {
      return bless {_ptr => $ptr}, $class;
    }
    return;
  }

  sub revision {
    my $self = shift;
    my $ptr = C::pkgcraft_version_revision($self->{_ptr});
    return Pkgcraft::Revision->_from_ptr($ptr);
  }

  use overload
    fallback => 1,
    '<=>' => sub {
      if ($_[0]->isa("Pkgcraft::Version") && $_[1]->isa("Pkgcraft::Version")) {
        return C::pkgcraft_version_cmp($_[0]->{_ptr}, $_[1]->{_ptr});
      }
      die "Invalid types for comparison!";
    },
    'cmp' => sub { "$_[0]" cmp "$_[1]"; },
    '""' => 'stringify';

  sub stringify {
    my $self = shift;
    return C::pkgcraft_version_str($self->{_ptr});
  }

  sub intersects {
    my $self = shift;
    my $other = shift // die "missing version object";
    return C::pkgcraft_version_intersects($self->{_ptr}, $other->{_ptr});
  }

  sub DESTROY {
    my $self = shift;
    C::pkgcraft_version_free($self->{_ptr});
  }
}

1;
