use Test2::V0;
use TOML::Tiny qw(from_toml);

use v5.30;
use strict;
use warnings;
no warnings qw(experimental);

use Pkgcraft::PkgDep;

# load test data
open my $fh, '<', 'testdata/toml/pkgdep.toml' or die "Can't open file: $!";
my $toml = do { local $/; <$fh> };
my ($PKGDEP_DATA, $err) = from_toml($toml);
unless ($PKGDEP_DATA) {
  die "Error parsing toml: $err";
}

# valid CPV
my $cpv = Pkgcraft::Cpv->new("cat/pkg-1");
ok($cpv->category eq "cat");
ok($cpv->package eq "pkg");
ok($cpv->version eq "1");
is($cpv->revision, undef);
ok($cpv->cpn eq "cat/pkg");
ok($cpv eq "cat/pkg-1");

# regular dep fails for CPV
ok(dies { Pkgcraft::Cpv->new("=cat/pkg-1") });

# invalid comparison types
ok(dies { $cpv == "cat/pkg-1" });

# missing string arg
ok(dies { Pkgcraft::Cpv->new() });

# valid comparisons
my $cpv2 = Pkgcraft::Cpv->new("cat/pkg-2");
ok($cpv != $cpv2);
ok($cpv < $cpv2);

# valid dep without EAPI
my $dep = Pkgcraft::PkgDep->new("=cat/pkg-1");
ok($dep->cpv eq "cat/pkg-1");

# missing string arg
ok(dies { Pkgcraft::PkgDep->new() });

# invalid dep with explicit EAPI (slot deps in EAPI >= 1)
ok(dies { Pkgcraft::PkgDep->new("cat/pkg:0", 0) });
$dep = Pkgcraft::PkgDep->new("cat/pkg:0", 1);
is($dep->slot, "0");

# repo dep without EAPI (defaults to extended support)
$dep = Pkgcraft::PkgDep->new("cat/pkg::repo");
ok($dep->repo eq "repo");

# invalid EAPI
like(
  dies { Pkgcraft::PkgDep->new("cat/pkg", "unknown") },
  qr/unknown EAPI: unknown/,
  "unknown EAPI: unknown"
);

# valid deps
foreach my $hash (@{$PKGDEP_DATA->{"valid"}}) {
  my %data = %$hash;
  my $eapis = Pkgcraft::Eapi::range($data{eapis});
  foreach my $eapi (@$eapis) {
    my $dep = Pkgcraft::PkgDep->new($data{dep}, $eapi);
    ok($dep->category eq $data{category});
    ok($dep->package eq $data{package});
    if (defined $data{blocker}) {
      is($dep->blocker, C::pkgcraft_pkgdep_blocker_from_str($data{blocker}));
    } else {
      is($dep->blocker, $data{blocker});
    }
    if (defined $data{version}) {
      ok($dep->version == Pkgcraft::VersionWithOp->new($data{version}));
    } else {
      is($dep->version, $data{version});
    }
    is($dep->revision, $data{revision});
    is($dep->slot, $data{slot});
    is($dep->subslot, $data{subslot});
    if (defined $data{slot_op}) {
      is($dep->slot_op, C::pkgcraft_pkgdep_slot_op_from_str($data{slot_op}));
    } else {
      is($dep->slot_op, $data{slot_op});
    }
    is($dep->use, $data{use});
    is($dep->repo, $data{repo});
    ok("$dep" eq $data{dep});
  }
}

# invalid deps
foreach my $str (@{$PKGDEP_DATA->{"invalid"}}) {
  like(
    dies { Pkgcraft::PkgDep->new($str) },
    qr/invalid pkgdep: \Q$str\E/,
    "invalid pkgdep: $str"
  );
}

# pkgdep comparisons
foreach my $str (@{$PKGDEP_DATA->{"compares"}}) {
  my ($s1, $op, $s2) = split ' ', $str;
  my $a1 = Pkgcraft::PkgDep->new($s1);
  my $a2 = Pkgcraft::PkgDep->new($s2);
  given ($op) {
    when ("<") { ok($a1 < $a2, $str) }
    when ("<=") { ok($a1 <= $a2, $str) }
    when ("==") { ok($a1 == $a2, $str) }
    when ("!=") { ok($a1 != $a2, $str) }
    when (">=") { ok($a1 >= $a2, $str) }
    when (">") { ok($a1 > $a2, $str) }
    default { die "unknown operator: $op" }
  }
}

# pkgdep sorting
foreach my $hash (@{$PKGDEP_DATA->{"sorting"}}) {
  my %data = %$hash;
  my @reversed = reverse @{$data{sorted}};
  my @sorted = sort { Pkgcraft::PkgDep->new($a) <=> Pkgcraft::PkgDep->new($b) } @reversed;

  # equal deps aren't sorted so reversing should restore the original order
  if ($data{equal}) {
    @sorted = reverse @sorted;
  }

  is(\@sorted, $data{sorted});
}

# TODO: use shared intersects test data
# intersects
my $a1 = Pkgcraft::PkgDep->new("=a/b-1.0.2");
my $a2 = Pkgcraft::PkgDep->new("=a/b-1.0.2-r0");
ok($a1->intersects($a2));
$a1 = Pkgcraft::PkgDep->new("=a/b-0");
$a2 = Pkgcraft::PkgDep->new("=a/b-1");
ok(!$a1->intersects($a2));
$a1 = Pkgcraft::Cpv->new("a/b-0");
$a2 = Pkgcraft::PkgDep->new("=a/b-0*");
ok($a1->intersects($a2));

done_testing;
