use Test2::V0;
use TOML::Tiny qw(from_toml);

use v5.30;
use strict;
use warnings;
no warnings qw(experimental);

use Pkgcraft::Cpv;

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

done_testing;
