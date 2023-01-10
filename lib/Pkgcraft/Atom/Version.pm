package Pkgcraft::Atom::Version;

use v5.30;
use strict;
use warnings;

use Pkgcraft;

$ffi->type('opaque' => 'version_t');
$ffi->attach('pkgcraft_version_new' => ['string'] => 'version_t');

sub new {
  my ($class, $str) = @_;
  my $ptr = pkgcraft_version_new($str);
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

$ffi->attach('pkgcraft_version_revision' => ['version_t'] => 'c_str');

sub revision {
  my ($self) = @_;
  return pkgcraft_version_revision($self->{_ptr});
}

$ffi->attach('pkgcraft_version_cmp' => ['version_t', 'version_t'] => 'int');

use overload
  fallback => 1,
  '<=>' => sub {
    if ($_[0]->isa("Pkgcraft::Atom::Version") && $_[1]->isa("Pkgcraft::Atom::Version")) {
      return pkgcraft_version_cmp($_[0]->{_ptr}, $_[1]->{_ptr});
    }
    die "Invalid types for comparison!";
  },
  'cmp' => sub { "$_[0]" cmp "$_[1]"; },
  '""' => 'stringify';

$ffi->attach('pkgcraft_version_str' => ['version_t'] => 'c_str');

sub stringify {
  my ($self) = @_;
  return pkgcraft_version_str($self->{_ptr});
}

$ffi->attach('pkgcraft_version_free' => ['version_t']);

sub DESTROY {
  my ($self) = @_;
  if (not($self->{ref})) {
    pkgcraft_version_free($self->{_ptr});
  }
}
