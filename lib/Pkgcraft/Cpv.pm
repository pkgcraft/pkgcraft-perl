package Pkgcraft::Cpv;

use v5.30;
use strict;
use warnings;

require _pkgcraft_c;
use Pkgcraft::Cpn;
use Pkgcraft::Version;

sub new {
  my $class = shift;
  my $str = shift // die "missing Cpn string";
  my $ptr = C::pkgcraft_cpv_new($str) // die "invalid Cpv: $str";
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

sub p {
  my $self = shift;
  return C::pkgcraft_cpv_p($self->{_ptr});
}

sub pf {
  my $self = shift;
  return C::pkgcraft_cpv_pf($self->{_ptr});
}

sub pr {
  my $self = shift;
  return C::pkgcraft_cpv_pr($self->{_ptr});
}

sub pv {
  my $self = shift;
  return C::pkgcraft_cpv_pv($self->{_ptr});
}

sub pvr {
  my $self = shift;
  return C::pkgcraft_cpv_pvr($self->{_ptr});
}

sub cpn {
  my $self = shift;
  my $ptr = C::pkgcraft_cpv_cpn($self->{_ptr});
  return Pkgcraft::Cpn->_from_ptr($ptr);
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
  my $other = shift // die "missing intersects object";
  if ($other->isa("Pkgcraft::Cpv")) {
    return C::pkgcraft_cpv_intersects($self, $other->{_ptr});
  } elsif ($other->isa("Pkgcraft::Dep")) {
    return C::pkgcraft_cpv_intersects_dep($self, $other->{_ptr});
  }
  die "Invalid type for intersects!";
}

sub DESTROY {
  my $self = shift;
  C::pkgcraft_cpv_free($self->{_ptr});
}
