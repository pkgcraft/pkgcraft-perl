package Pkgcraft::Eapi;

use v5.30;
use strict;
use warnings;

use Pkgcraft;

use Storable qw(dclone);
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw($EAPIS_OFFICIAL $EAPIS $EAPI_LATEST);

$ffi->type('opaque' => 'eapi_t');
$ffi->attach('pkgcraft_eapi_as_str' => ['eapi_t'] => 'c_str');

sub _eapis_to_hash {
  my ($arr_ptr, $length, $start) = @_;
  my $arr = cast_array($arr_ptr);
  my %eapis;
  foreach my $elem ($start .. $length - 1) {
    my $ptr = $arr->[$elem];
    my $id = pkgcraft_eapi_as_str($ptr);
    my $eapi = bless {_ptr => $ptr, _id => $id}, "Pkgcraft::Eapi";
    $eapis{$id} = $eapi;
  }
  return %eapis;
}

$ffi->attach('pkgcraft_eapis_official' => ['int*'] => 'opaque');
$ffi->attach('pkgcraft_eapis_free' => ['opaque', 'int']);

sub _get_official_eapis {
  my $length = 0;
  my $ptr = pkgcraft_eapis_official(\$length);
  my %eapis = _eapis_to_hash($ptr, $length, 0);
  pkgcraft_eapis_free($ptr, $length);
  return \%eapis;
}

our $EAPIS_OFFICIAL = _get_official_eapis();
our $EAPI_LATEST = %{$EAPIS_OFFICIAL}{(keys %{$EAPIS_OFFICIAL}) - 1};

$ffi->attach('pkgcraft_eapis' => ['int*'] => 'opaque');

sub _get_eapis {
  my $length = 0;
  my %eapis_official = %{dclone($EAPIS_OFFICIAL)};
  my $eapis_official_len = keys %eapis_official;
  my $ptr = pkgcraft_eapis(\$length);
  my %eapis_unofficial = _eapis_to_hash($ptr, $length, $eapis_official_len);
  my %eapis = (%eapis_official, %eapis_unofficial);
  pkgcraft_eapis_free($ptr, $length);
  return \%eapis;
}

our $EAPIS = _get_eapis();

$ffi->attach('pkgcraft_eapi_cmp' => ['eapi_t', 'eapi_t'] => 'int');

use overload
  fallback => 1,
  '<=>' => sub {
    if ($_[0]->isa("Pkgcraft::Eapi") && $_[1]->isa("Pkgcraft::Eapi")) {
      return pkgcraft_eapi_cmp($_[0]->{_ptr}, $_[1]->{_ptr});
    }
    die "Invalid types for comparison!";
  },
  'cmp' => sub { "$_[0]" cmp "$_[1]"; },
  '""' => sub { $_[0]->{_id} };
