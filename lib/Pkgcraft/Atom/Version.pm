package Pkgcraft::Atom::Version;

use Pkgcraft;

$ffi->type('opaque' => 'version_t');

$ffi->attach(pkgcraft_version_new => ['string'] => 'version_t');

sub new {
  my $class = shift;
  my $str   = shift;
  my $ptr   = pkgcraft_version_new($str);
  if (defined $ptr) {
    return bless {_ptr => $ptr, ref => 0}, $class;
  }
  die "invalid version: $str";
}

sub _from_ptr {
  my $class = shift;
  my $ptr   = shift;
  if (defined $ptr) {
    return bless {_ptr => $ptr, ref => 1}, $class;
  }
  return;
}

$ffi->attach(pkgcraft_version_revision => ['version_t'] => 'c_str');

sub revision {
  my $self = shift;
  return pkgcraft_version_revision($self->{_ptr});
}

use overload
  fallback => 0,
  '<'      => sub { $_[0]->cmp($_[1]) == -1; },
  '<='     => sub { $_[0]->cmp($_[1]) <= 0; },
  '=='     => sub { $_[0]->cmp($_[1]) == 0; },
  '!='     => sub { $_[0]->cmp($_[1]) != 0; },
  '>='     => sub { $_[0]->cmp($_[1]) >= 0; },
  '>'      => sub { $_[0]->cmp($_[1]) == 1; },
  '""'     => 'stringify';

$ffi->attach(pkgcraft_version_cmp => ['version_t', 'version_t'] => 'int');

sub cmp {
  my $self  = shift;
  my $other = shift;
  return pkgcraft_version_cmp($self->{_ptr}, $other->{_ptr});
}

$ffi->attach(pkgcraft_version_str => ['version_t'] => 'c_str');

sub stringify {
  my $self = shift;
  return pkgcraft_version_str($self->{_ptr});
}

$ffi->attach(pkgcraft_version_free => ['version_t']);

sub DESTROY {
  my $self = shift;
  if (not($self->{ref})) {
    pkgcraft_version_free($self->{_ptr});
  }
}
