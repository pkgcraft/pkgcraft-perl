package Pkgcraft::Dep;

use v5.30;
use strict;
use warnings;

require _pkgcraft_c;
use Pkgcraft::Eapi;
use Pkgcraft::Version;

use constant {BLOCKER_STRONG => 1, BLOCKER_WEAK => 2};
use constant {SLOT_OPERATOR_EQUAL => 1, SLOT_OPERATOR_STAR => 2};

sub new {
  my $class = shift;
  my $str = shift // die "missing dep string";
  my $eapi = shift;

  my $eapi_ptr = undef;
  if (defined $eapi) {
    my $id = $eapi;
    $eapi = EAPIS($id) // die "unknown EAPI: $id";
    $eapi_ptr = $eapi->{_ptr};
  }

  my $ptr = C::pkgcraft_dep_new($str, $eapi_ptr) // die "invalid dep: $str";
  return bless {_ptr => $ptr}, $class;
}

sub blocker {
  my $self = shift;
  my $blocker = C::pkgcraft_dep_blocker($self->{_ptr});
  if ($blocker > 0) {
    return $blocker;
  }
  return;
}

sub category {
  my $self = shift;
  return C::pkgcraft_dep_category($self->{_ptr});
}

sub package {
  my $self = shift;
  return C::pkgcraft_dep_package($self->{_ptr});
}

sub version {
  my $self = shift;
  my $ptr = C::pkgcraft_dep_version($self->{_ptr});
  return Pkgcraft::Version->_from_ptr($ptr);
}

sub revision {
  my $self = shift;
  my $version = $self->version;
  if (defined $version) {
    return $version->revision;
  }
  return;
}

sub slot {
  my $self = shift;
  return C::pkgcraft_dep_slot($self->{_ptr});
}

sub subslot {
  my $self = shift;
  return C::pkgcraft_dep_subslot($self->{_ptr});
}

sub slot_op {
  my $self = shift;
  my $slot_op = C::pkgcraft_dep_slot_op($self->{_ptr});
  if ($slot_op > 0) {
    return $slot_op;
  }
  return;
}

sub use {
  my $self = shift;
  my $length = 0;
  my $use = C::pkgcraft_dep_use_deps_str($self->{_ptr}, \$length);
  return C::string_array($use, $length);
}

sub repo {
  my $self = shift;
  return C::pkgcraft_dep_repo($self->{_ptr});
}

sub cpn {
  my $self = shift;
  return C::pkgcraft_dep_cpn($self->{_ptr});
}

sub cpv {
  my $self = shift;
  return C::pkgcraft_dep_cpv($self->{_ptr});
}

use overload
  fallback => 1,
  '<=>' => sub {
    if ($_[0]->isa("Pkgcraft::Dep") && $_[1]->isa("Pkgcraft::Dep")) {
      return C::pkgcraft_dep_cmp($_[0]->{_ptr}, $_[1]->{_ptr});
    }
    die "Invalid types for comparison!";
  },
  'cmp' => sub { "$_[0]" cmp "$_[1]"; },
  '""' => 'stringify';

sub stringify {
  my $self = shift;
  return C::pkgcraft_dep_str($self->{_ptr});
}

sub intersects {
  my $self = shift->{_ptr};
  my $other = shift // die "missing intersects object";
  if ($other->isa("Pkgcraft::Dep")) {
    return C::pkgcraft_dep_intersects($self, $other->{_ptr});
  } elsif ($other->isa("Pkgcraft::Cpv")) {
    return C::pkgcraft_dep_intersects_cpv($self, $other->{_ptr});
  }
  die "Invalid type for intersects!";
}

sub DESTROY {
  my $self = shift;
  C::pkgcraft_dep_free($self->{_ptr});
}

1;
