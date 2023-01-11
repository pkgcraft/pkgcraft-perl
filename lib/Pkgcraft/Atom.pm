package Pkgcraft::Atom;

use v5.30;
use strict;
use warnings;

require _pkgcraft_c;
use Pkgcraft::Eapi;
use parent 'Pkgcraft::Cpv';

use constant {BLOCKER_STRONG => 0, BLOCKER_WEAK => 1};
use constant {SLOT_OPERATOR_EQUAL => 0, SLOT_OPERATOR_STAR => 1};

sub new {
  my ($class, $str, $eapi) = @_;

  my $eapi_ptr = undef;
  if (defined $eapi) {
    if (!$eapi->isa("Pkgcraft::Eapi")) {
      my $id = $eapi;
      $eapi = EAPIS($id) or die "unknown EAPI: $id";
    }
    $eapi_ptr = $eapi->{_ptr};
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

1;
