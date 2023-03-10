use Test2::V0;
use TOML::Tiny qw(from_toml);

use v5.30;
use strict;
use warnings;
no warnings qw(experimental);

use Pkgcraft::Cpv;
use Pkgcraft::Dep;

# revisioned
my $cpv = Pkgcraft::Cpv->new("cat/pkg-1-r2");
ok($cpv->category eq "cat");
ok($cpv->package eq "pkg");
ok($cpv->version eq "1-r2");
ok($cpv->revision eq "2");
ok($cpv->p eq "pkg-1");
ok($cpv->pf eq "pkg-1-r2");
ok($cpv->pr eq "r2");
ok($cpv->pv eq "1");
ok($cpv->pvr eq "1-r2");
ok($cpv->cpn eq "cat/pkg");
ok($cpv eq "cat/pkg-1-r2");

# unrevisioned
$cpv = Pkgcraft::Cpv->new("cat/pkg-1");
ok($cpv->category eq "cat");
ok($cpv->package eq "pkg");
ok($cpv->version eq "1");
is($cpv->revision, undef);
ok($cpv->p eq "pkg-1");
ok($cpv->pf eq "pkg-1");
ok($cpv->pr eq "r0");
ok($cpv->pv eq "1");
ok($cpv->pvr eq "1");
ok($cpv->cpn eq "cat/pkg");
ok($cpv eq "cat/pkg-1");

# regular dep fails for CPV
ok(dies { Pkgcraft::Cpv->new("=cat/pkg-1") });

# invalid comparison types
ok(dies { $cpv == "cat/pkg-1" });

# missing string arg
ok(dies { Pkgcraft::Cpv->new() });

# valid comparisons
my $cpv1 = Pkgcraft::Cpv->new("cat/pkg-1");
my $cpv2 = Pkgcraft::Cpv->new("cat/pkg-2");
ok($cpv != $cpv2);
ok($cpv < $cpv2);

# intersects
$cpv1 = Pkgcraft::Cpv->new("a/b-1");
$cpv2 = Pkgcraft::Cpv->new("a/b-2");
ok($cpv1->intersects($cpv1));
ok(!$cpv1->intersects($cpv2));

# Dep intersects
my $dep = Pkgcraft::Dep->new("=a/b-1");
ok($cpv1->intersects($dep));
ok(!$cpv2->intersects($dep));

# invalid type
ok(dies { $cpv->intersects("") });

done_testing;
