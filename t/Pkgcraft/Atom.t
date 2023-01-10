use Test2::V0;
use TOML::Tiny qw(from_toml);

use v5.30;
use strict;
use warnings;

use Pkgcraft::Atom;

# load test data
open my $fh, '<', 'testdata/toml/atom.toml' or die "Can't open file: $!";
my $toml = do { local $/; <$fh> };
my ($ATOM_DATA, $err) = from_toml($toml);
unless ($ATOM_DATA) {
  die "Error parsing toml: $err";
}

my $cpv = Pkgcraft::Cpv->new("cat/pkg-1");
ok($cpv->category eq "cat");
ok($cpv->package eq "pkg");
ok($cpv->version eq "1");
ok($cpv->revision eq "0");
ok($cpv->cpn eq "cat/pkg");
ok($cpv eq "cat/pkg-1");
ok(sprintf("%s", $cpv) eq "cat/pkg-1");

my $atom = Pkgcraft::Atom->new("cat/pkg");
ok($atom->category eq "cat");
ok($atom->package eq "pkg");
is($atom->version, undef);
is($atom->revision, undef);
ok($atom->cpn eq "cat/pkg");
is($atom->blocker, undef);
is($atom->slot, undef);
is($atom->subslot, undef);
is($atom->slot_op, undef);
is($atom->repo, undef);
is($atom->use, undef);
ok($atom->cpv eq "cat/pkg");
ok($atom eq "cat/pkg");
ok(sprintf("%s", $atom) eq "cat/pkg");

$atom = Pkgcraft::Atom->new("!cat/pkg[u1,u2]");
is($atom->blocker, Pkgcraft::Atom->BLOCKER_WEAK);
is($atom->use, ["u1", "u2"]);

$atom = Pkgcraft::Atom->new("cat/pkg:1=");
ok($atom->slot eq "1");
is($atom->slot_op, Pkgcraft::Atom->SLOT_OPERATOR_EQUAL);

$ffi->attach('pkgcraft_atom_blocker_from_str' => ['string'] => 'int');
$ffi->attach('pkgcraft_atom_slot_op_from_str' => ['string'] => 'int');

# valid atoms
foreach my $hash (@{$ATOM_DATA->{"valid"}}) {
  my %data = %$hash;
  my $eapis = Pkgcraft::Eapi->range($data{eapis});
  foreach my $eapi (@$eapis) {
    my $atom = Pkgcraft::Atom->new($data{atom}, $eapi);
    ok($atom->category eq $data{category});
    ok($atom->package eq $data{package});
    if (defined $data{blocker}) {
      is($atom->blocker, pkgcraft_atom_blocker_from_str($data{blocker}));
    } else {
      is($atom->blocker, $data{blocker});
    }
    if (defined $data{version}) {
      ok($atom->version == Pkgcraft::Atom::VersionWithOp->new($data{version}));
    } else {
      is($atom->version, $data{version});
    }
    is($atom->revision, $data{revision});
    is($atom->slot, $data{slot});
    is($atom->subslot, $data{subslot});
    if (defined $data{slot_op}) {
      is($atom->slot_op, pkgcraft_atom_slot_op_from_str($data{slot_op}));
    } else {
      is($atom->slot_op, $data{slot_op});
    }
    is($atom->use, $data{use});
    ok("$atom" eq $data{atom});
  }
}

# invalid atoms
foreach my $str (@{$ATOM_DATA->{"invalid"}}) {
  like(
    dies { Pkgcraft::Atom->new($str) },
    qr/invalid atom: \Q$str\E/,
    "invalid atom: $str"
  );
}

# equivalent atoms with unequal strings
foreach my $str (@{$ATOM_DATA->{"compares"}}) {
  my ($s1, $op, $s2) = split ' ', $str;
  my $a1 = Pkgcraft::Atom->new($s1);
  my $a2 = Pkgcraft::Atom->new($s2);
  ok($a1 == $a2);
  ok($a1 ne $a2);
}

# atom sorting
foreach my $arrays (@{$ATOM_DATA->{"sorting"}}) {
  my ($unsorted, $expected) = @$arrays;
  my @sorted = sort { Pkgcraft::Atom->new($a) <=> Pkgcraft::Atom->new($b) } @$unsorted;
  is(\@sorted, $expected);
}

done_testing;
