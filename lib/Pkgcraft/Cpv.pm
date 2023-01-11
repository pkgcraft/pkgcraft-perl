package Pkgcraft::Cpv;

use v5.30;
use strict;
use warnings;

require _pkgcraft_c;
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
