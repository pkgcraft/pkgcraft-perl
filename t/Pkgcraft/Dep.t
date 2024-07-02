use Test2::V0;
use TOML::Tiny qw(from_toml);

use v5.30;
use strict;
use warnings;
no warnings qw(experimental);

use Pkgcraft::Cpv;
use Pkgcraft::Dep;

# load test data
open my $fh, '<', 'testdata/toml/dep.toml' or die "Can't open file: $!";
my $toml = do { local $/; <$fh> };
my ($DEP_DATA, $err) = from_toml($toml);
unless ($DEP_DATA) {
  die "Error parsing toml: $err";
}

# valid dep without EAPI
my $dep = Pkgcraft::Dep->new("=cat/pkg-1");
my $cpv = Pkgcraft::Cpv->new("cat/pkg-1");
ok($dep->cpv eq $cpv);

# missing string arg
ok(dies { Pkgcraft::Dep->new() });

# explicit EAPI
ok(dies { Pkgcraft::Dep->new("cat/pkg::repo", 8) });
$dep = Pkgcraft::Dep->new("cat/pkg:0", 8);
is($dep->slot, "0");

# repo dep without EAPI (defaults to extended support)
$dep = Pkgcraft::Dep->new("cat/pkg::repo");
ok($dep->repo eq "repo");

# invalid EAPI
like(
  dies { Pkgcraft::Dep->new("cat/pkg", "unknown") },
  qr/unknown EAPI: unknown/,
  "unknown EAPI: unknown"
);

# valid deps
foreach my $hash (@{$DEP_DATA->{"valid"}}) {
  my %data = %$hash;
  my $eapis = Pkgcraft::Eapi::range($data{eapis});
  foreach my $eapi (@$eapis) {
    my $dep = Pkgcraft::Dep->new($data{dep}, $eapi);
    ok($dep->category eq $data{category});
    ok($dep->package eq $data{package});
    if (defined $data{blocker}) {
      is($dep->blocker, C::pkgcraft_dep_blocker_from_str($data{blocker}));
    } else {
      is($dep->blocker, $data{blocker});
    }
    if (defined $data{version}) {
      ok($dep->version == Pkgcraft::Version->new($data{version}));
    } else {
      is($dep->version, $data{version});
    }
    if (defined $data{revision}) {
      ok($dep->revision == Pkgcraft::Revision->new($data{revision}));
    } else {
      is($dep->revision, $data{revision});
    }
    is($dep->slot, $data{slot});
    is($dep->subslot, $data{subslot});
    if (defined $data{slot_op}) {
      is($dep->slot_op, C::pkgcraft_dep_slot_op_from_str($data{slot_op}));
    } else {
      is($dep->slot_op, $data{slot_op});
    }
    is($dep->use, $data{use});
    is($dep->repo, $data{repo});
    ok("$dep" eq $data{dep});
  }
}

# invalid deps
foreach my $str (@{$DEP_DATA->{"invalid"}}) {
  like(dies { Pkgcraft::Dep->new($str) }, qr/invalid Dep: \Q$str\E/, "invalid Dep: $str");
}

# dep comparisons
foreach my $str (@{$DEP_DATA->{"compares"}}) {
  my ($s1, $op, $s2) = split ' ', $str;
  my $d1 = Pkgcraft::Dep->new($s1);
  my $d2 = Pkgcraft::Dep->new($s2);
  if ($op eq "<") { ok($d1 < $d2, $str) }
  elsif ($op eq "<=") { ok($d1 <= $d2, $str) }
  elsif ($op eq "==") { ok($d1 == $d2, $str) }
  elsif ($op eq "!=") { ok($d1 != $d2, $str) }
  elsif ($op eq ">=") { ok($d1 >= $d2, $str) }
  elsif ($op eq ">") { ok($d1 > $d2, $str) }
  else { die "unknown operator: $op" }
}

# dep sorting
foreach my $hash (@{$DEP_DATA->{"sorting"}}) {
  my %data = %$hash;
  my @reversed = reverse @{$data{sorted}};
  my @sorted = sort { Pkgcraft::Dep->new($a) <=> Pkgcraft::Dep->new($b) } @reversed;

  # equal deps aren't sorted so reversing should restore the original order
  if ($data{equal}) {
    @sorted = reverse @sorted;
  }

  is(\@sorted, $data{sorted});
}

# intersects
foreach my $hash (@{$DEP_DATA->{"intersects"}}) {
  my %data = %$hash;
  my @vals = @{$data{vals}};

  # TODO: loop over all element pair permutations
  for (0 .. $#vals - 1) {
    my $v1 = Pkgcraft::Dep->new($vals[$_]);
    my $v2 = Pkgcraft::Dep->new($vals[$_ + 1]);

    # elements intersect themselves
    ok($v1->intersects($v1));
    ok($v2->intersects($v2));

    # equal versions aren't sorted so reversing should restore the original order
    if ($data{status}) {
      ok($v1->intersects($v2));
    } else {
      ok(!$v1->intersects($v2));
    }
  }
}

# Cpv intersects
$cpv = Pkgcraft::Cpv->new("a/b-1");
$dep = Pkgcraft::Dep->new("=a/b-1");
ok($dep->intersects($cpv));

# missing argument
ok(dies { $dep->intersects() });

# invalid type
ok(dies { $dep->intersects("=a/b-1") });

done_testing;
