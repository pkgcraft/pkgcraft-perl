package Pkgcraft::PkgDep;

use v5.30;
use strict;
use warnings;

require _pkgcraft_c;
use Pkgcraft::Eapi;
use parent 'Pkgcraft::Cpv';

use constant {BLOCKER_STRONG => 1, BLOCKER_WEAK => 2};
use constant {SLOT_OPERATOR_EQUAL => 1, SLOT_OPERATOR_STAR => 2};

sub new {
  my $class = shift;
  my $str = shift // die "missing pkgdep string";
  my $eapi = shift;

  my $eapi_ptr = undef;
  if (defined $eapi) {
    my $id = $eapi;
    $eapi = EAPIS($id) // die "unknown EAPI: $id";
    $eapi_ptr = $eapi->{_ptr};
  }

  my $ptr = C::pkgcraft_pkgdep_new($str, $eapi_ptr) // die "invalid pkgdep: $str";
  return bless {_ptr => $ptr}, $class;
}

sub blocker {
  my $self = shift;
  my $blocker = C::pkgcraft_pkgdep_blocker($self->{_ptr});
  if ($blocker > 0) {
    return $blocker;
  }
  return;
}

sub slot {
  my $self = shift;
  return C::pkgcraft_pkgdep_slot($self->{_ptr});
}

sub subslot {
  my $self = shift;
  return C::pkgcraft_pkgdep_subslot($self->{_ptr});
}

sub slot_op {
  my $self = shift;
  my $slot_op = C::pkgcraft_pkgdep_slot_op($self->{_ptr});
  if ($slot_op > 0) {
    return $slot_op;
  }
  return;
}

sub use {
  my $self = shift;
  my $length = 0;
  my $use = C::pkgcraft_pkgdep_use_deps($self->{_ptr}, \$length);
  return C::string_array($use, $length);
}

sub repo {
  my $self = shift;
  return C::pkgcraft_pkgdep_repo($self->{_ptr});
}

sub cpv {
  my $self = shift;
  return C::pkgcraft_pkgdep_cpv($self->{_ptr});
}

1;
