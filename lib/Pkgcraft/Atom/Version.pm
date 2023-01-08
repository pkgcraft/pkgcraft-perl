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
  else {
    die "invalid version: $str";
  }
}

$ffi->attach(pkgcraft_version_revision => ['version_t'] => 'opaque');

sub revision {
  my $self = shift;
  my $ptr  = pkgcraft_version_revision($self->{_ptr});
  my $str  = $ffi->cast('opaque' => 'string', $ptr);
  pkgcraft_str_free($ptr);
  return $str;
}

use overload
  fallback => 0,
  '""'     => 'stringify';

$ffi->attach(pkgcraft_version_str => ['version_t'] => 'opaque');

sub stringify {
  my $self = shift;
  my $ptr  = pkgcraft_version_str($self->{_ptr});
  my $str  = $ffi->cast('opaque' => 'string', $ptr);
  pkgcraft_str_free($ptr);
  return $str;
}

$ffi->attach(pkgcraft_version_free => ['version_t']);

sub DESTROY {
  my $self = shift;
  if (not($self->{ref})) {
    pkgcraft_version_free($self->{_ptr});
  }
}
