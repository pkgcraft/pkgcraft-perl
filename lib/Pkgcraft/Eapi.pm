package Pkgcraft::Eapi;

use v5.30;
use strict;
use warnings;

require _pkgcraft_c;

use Storable qw(dclone);
use parent 'Exporter';
our @EXPORT = qw(EAPIS_OFFICIAL EAPIS $EAPI_LATEST);

my $eapis_to_array = sub {
  my ($arr_ptr, $length, $start) = @_;
  my $arr = C::cast_array($arr_ptr);
  my @eapis;
  foreach my $elem ($start .. $length - 1) {
    my $ptr = $arr->[$elem];
    my $id = C::pkgcraft_eapi_as_str($ptr);
    push @eapis, bless {_ptr => $ptr, _id => $id}, "Pkgcraft::Eapi";
  }
  return @eapis;
};

my $eapis_to_hash = sub {
  my $arr = shift;
  my %eapis;
  foreach (@$arr) {
    $eapis{$_} = $_;
  }
  return %eapis;
};

my $get_eapis_official = sub {
  my $length = 0;
  my $ptr = C::pkgcraft_eapis_official(\$length);
  my @eapis = &$eapis_to_array($ptr, $length, 0);
  C::pkgcraft_eapis_free($ptr, $length);
  return @eapis;
};

my @eapis_official = &$get_eapis_official();
my %eapis_official = &$eapis_to_hash(\@eapis_official);
our $EAPI_LATEST = $eapis_official[$#eapis_official];

sub EAPIS_OFFICIAL {
  my $id = shift;
  defined $id ? $eapis_official{$id} : \%eapis_official;
}

my $get_eapis_unofficial = sub {
  my $length = 0;
  my $ptr = C::pkgcraft_eapis(\$length);
  my @eapis = &$eapis_to_array($ptr, $length, $#eapis_official);
  C::pkgcraft_eapis_free($ptr, $length);
  return @eapis;
};

my @eapis_unofficial = &$get_eapis_unofficial();
my @eapis = (@eapis_official, @eapis_unofficial);
my %eapis = &$eapis_to_hash(\@eapis);

sub EAPIS {
  my $id = shift;
  defined $id ? $eapis{$id} : \%eapis;
}

use overload
  fallback => 1,
  '<=>' => sub {
    if ($_[0]->isa("Pkgcraft::Eapi") && $_[1]->isa("Pkgcraft::Eapi")) {
      return C::pkgcraft_eapi_cmp($_[0]->{_ptr}, $_[1]->{_ptr});
    }
    die "Invalid types for comparison!";
  },
  'cmp' => sub { "$_[0]" cmp "$_[1]"; },
  '""' => sub { $_[0]->{_id} };

sub range {
  my $str = shift;
  my $length = 0;
  my $ptr = C::pkgcraft_eapis_range($str, \$length) or die "invalid EAPI range: $str";
  my @eapis = &$eapis_to_array($ptr, $length, 0);
  C::pkgcraft_eapis_free($ptr, $length);
  return \@eapis;
}

1;
