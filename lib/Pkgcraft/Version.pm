use v5.30;
use strict;
use warnings;

require _pkgcraft_c;

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
    return C::pkgcraft_version_revision($self->{_ptr});
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
    my $self = shift->{_ptr};
    my $other = shift->{_ptr} // die "missing version object";
    return C::pkgcraft_version_intersects($self, $other);
  }

  sub DESTROY {
    my $self = shift;
    C::pkgcraft_version_free($self->{_ptr});
  }
}

package Pkgcraft::VersionWithOp {
  use parent 'Pkgcraft::Version';

  sub new {
    my $class = shift;
    my $str = shift // die "missing version string";
    my $ptr = C::pkgcraft_version_with_op($str)
      // die "invalid version with operator: $str";
    return bless {_ptr => $ptr}, $class;
  }

  sub stringify {
    my $self = shift;
    return C::pkgcraft_version_str_with_op($self->{_ptr});
  }
}

1;
