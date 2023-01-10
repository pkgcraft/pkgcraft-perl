package Pkgcraft::Eapi;

use v5.30;
use strict;
use warnings;

use Pkgcraft;

use Storable qw(dclone);
use parent 'Exporter';
our @EXPORT = qw(EAPIS_OFFICIAL EAPIS $EAPI_LATEST);

$ffi->type('opaque' => 'eapi_t');
$ffi->attach('pkgcraft_eapi_as_str' => ['eapi_t'] => 'c_str');

sub _eapis_to_array {
  my ($arr_ptr, $length, $start) = @_;
  my $arr = cast_array($arr_ptr);
  my @eapis;
  foreach my $elem ($start .. $length - 1) {
    my $ptr = $arr->[$elem];
    my $id = pkgcraft_eapi_as_str($ptr);
    push @eapis, bless {_ptr => $ptr, _id => $id}, "Pkgcraft::Eapi";
  }
  return @eapis;
}

$ffi->attach('pkgcraft_eapis_official' => ['int*'] => 'opaque');
$ffi->attach('pkgcraft_eapis_free' => ['opaque', 'int']);

sub _get_official_eapis {
  my $length = 0;
  my $ptr = pkgcraft_eapis_official(\$length);
  my @arr = _eapis_to_array($ptr, $length, 0);
  pkgcraft_eapis_free($ptr, $length);

  # convert array into hash
  my %eapis;
  foreach (@arr) {
    $eapis{$_} = $_;
  }

  return %eapis;
}

sub EAPIS_OFFICIAL {
  state %eapis = _get_official_eapis();
  my $id = shift;
  defined $id ? $eapis{$id} : \%eapis;
}

our $EAPI_LATEST = EAPIS_OFFICIAL((keys %{EAPIS_OFFICIAL()}) - 1);

$ffi->attach('pkgcraft_eapis' => ['int*'] => 'opaque');

sub _get_eapis {
  my %eapis_official = %{dclone(EAPIS_OFFICIAL())};
  my $eapis_official_len = keys %eapis_official;

  my $length = 0;
  my $ptr = pkgcraft_eapis(\$length);
  my @arr = _eapis_to_array($ptr, $length, $eapis_official_len);
  pkgcraft_eapis_free($ptr, $length);

  # convert array into hash
  my %eapis_unofficial;
  foreach (@arr) {
    $eapis_unofficial{$_} = $_;
  }

  return (%eapis_official, %eapis_unofficial);
}

sub EAPIS {
  state %eapis = _get_eapis();
  my $id = shift;
  defined $id ? $eapis{$id} : \%eapis;
}

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

$ffi->attach('pkgcraft_eapis_range' => ['string', 'int*'] => 'opaque');

sub range {
  my ($class, $str) = @_;
  my $length = 0;
  my $ptr = pkgcraft_eapis_range($str, \$length) or die "invalid EAPI range: $str";
  my @eapis = _eapis_to_array($ptr, $length, 0);
  pkgcraft_eapis_free($ptr, $length);
  return \@eapis;
}
