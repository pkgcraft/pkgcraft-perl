package Pkgcraft::Cpn;

use v5.30;
use strict;
use warnings;

require _pkgcraft_c;
use Pkgcraft::Version;

sub new {
  my $class = shift;
  my $str = shift // die "missing Cpn string";
  my $ptr = C::pkgcraft_cpn_new($str) // die "invalid Cpn: $str";
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
  return C::pkgcraft_cpn_category($self->{_ptr});
}

sub package {
  my $self = shift;
  return C::pkgcraft_cpn_package($self->{_ptr});
}

use overload
  fallback => 1,
  '<=>' => sub {
    if ($_[0]->isa("Pkgcraft::Cpn") && $_[1]->isa("Pkgcraft::Cpn")) {
      return C::pkgcraft_cpn_cmp($_[0]->{_ptr}, $_[1]->{_ptr});
    }
    die "Invalid types for comparison!";
  },
  'cmp' => sub { "$_[0]" cmp "$_[1]"; },
  '""' => 'stringify';

sub stringify {
  my $self = shift;
  return C::pkgcraft_cpn_str($self->{_ptr});
}

sub DESTROY {
  my $self = shift;
  C::pkgcraft_cpn_free($self->{_ptr});
}
