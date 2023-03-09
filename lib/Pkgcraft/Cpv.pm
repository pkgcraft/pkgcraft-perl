package Pkgcraft::Cpv;

use v5.30;
use strict;
use warnings;

require _pkgcraft_c;
use Pkgcraft::Version;

sub new {
  my $class = shift;
  my $str = shift // die "missing CPV string";
  my $ptr = C::pkgcraft_cpv_new($str) // die "invalid CPV: $str";
  return bless {_ptr => $ptr}, $class;
}

sub _from_ptr {
  my ($class, $ptr) = @_;
  if (defined $ptr) {
    return bless {_ptr => $ptr}, $class;
  }
  return;
}

sub category {
  my $self = shift;
  return C::pkgcraft_cpv_category($self->{_ptr});
}

sub package {
  my $self = shift;
  return C::pkgcraft_cpv_package($self->{_ptr});
}

sub version {
  my $self = shift;
  my $ptr = C::pkgcraft_cpv_version($self->{_ptr});
  return Pkgcraft::Version->_from_ptr($ptr);
}

sub revision {
  my $self = shift;
  return $self->version->revision;
}

sub cpn {
  my $self = shift;
  return C::pkgcraft_cpv_cpn($self->{_ptr});
}

use overload
  fallback => 1,
  '<=>' => sub {
    if ($_[0]->isa("Pkgcraft::Cpv") && $_[1]->isa("Pkgcraft::Cpv")) {
      return C::pkgcraft_cpv_cmp($_[0]->{_ptr}, $_[1]->{_ptr});
    }
    die "Invalid types for comparison!";
  },
  'cmp' => sub { "$_[0]" cmp "$_[1]"; },
  '""' => 'stringify';

sub stringify {
  my $self = shift;
  return C::pkgcraft_cpv_str($self->{_ptr});
}

sub intersects {
  my $self = shift->{_ptr};
  my $other = shift->{_ptr} // die "missing dep object";
  return C::pkgcraft_cpv_intersects($self, $other);
}

sub DESTROY {
  my $self = shift;
  C::pkgcraft_cpv_free($self->{_ptr});
}
