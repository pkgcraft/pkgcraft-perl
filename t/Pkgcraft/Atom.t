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

# valid CPV
my $cpv = Pkgcraft::Cpv->new("cat/pkg-1");
ok($cpv->category eq "cat");
ok($cpv->package eq "pkg");
ok($cpv->version eq "1");
ok($cpv->revision eq "0");
ok($cpv->cpn eq "cat/pkg");
ok($cpv eq "cat/pkg-1");

# regular atom fails for CPV
ok(dies { Pkgcraft::Cpv->new("=cat/pkg-1") });

# invalid comparison types
ok(dies { $cpv == "cat/pkg-1" });

# missing string arg
ok(dies { Pkgcraft::Cpv->new() });

# valid comparisons
my $cpv2 = Pkgcraft::Cpv->new("cat/pkg-2");
ok($cpv != $cpv2);
ok($cpv < $cpv2);

# valid atom without EAPI
my $atom = Pkgcraft::Atom->new("=cat/pkg-1");
ok($atom->cpv eq "cat/pkg-1");

# missing string arg
ok(dies { Pkgcraft::Atom->new() });

# invalid atom with explicit EAPI (slot deps in EAPI >= 1)
ok(dies { Pkgcraft::Atom->new("cat/pkg:0", 0) });
$atom = Pkgcraft::Atom->new("cat/pkg:0", 1);
is($atom->slot, "0");

# repo dep without EAPI (defaults to extended support)
$atom = Pkgcraft::Atom->new("cat/pkg::repo");
ok($atom->repo eq "repo");

# invalid EAPI
like(
  dies { Pkgcraft::Atom->new("cat/pkg", "unknown") },
  qr/unknown EAPI: unknown/,
  "unknown EAPI: unknown"
);

# valid atoms
foreach my $hash (@{$ATOM_DATA->{"valid"}}) {
  my %data = %$hash;
  my $eapis = Pkgcraft::Eapi::range($data{eapis});
  foreach my $eapi (@$eapis) {
    my $atom = Pkgcraft::Atom->new($data{atom}, $eapi);
    ok($atom->category eq $data{category});
    ok($atom->package eq $data{package});
    if (defined $data{blocker}) {
      is($atom->blocker, C::pkgcraft_atom_blocker_from_str($data{blocker}));
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
      is($atom->slot_op, C::pkgcraft_atom_slot_op_from_str($data{slot_op}));
    } else {
      is($atom->slot_op, $data{slot_op});
    }
    is($atom->use, $data{use});
    is($atom->repo, $data{repo});
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
  my ($expected, $equal) = @$arrays;
  my @reversed = reverse @$expected;
  my @sorted = sort { Pkgcraft::Atom->new($a) <=> Pkgcraft::Atom->new($b) } @reversed;

  # equal atoms aren't sorted so reversing should restore the original order
  if ($equal) {
    @sorted = reverse @sorted;
  }

  is(\@sorted, $expected);
}

done_testing;
