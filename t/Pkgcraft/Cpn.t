use Test2::V0;
use TOML::Tiny qw(from_toml);

use v5.30;
use strict;
use warnings;
no warnings qw(experimental);

use Pkgcraft::Cpn;

# valid
my $cpn = Pkgcraft::Cpn->new("cat/pkg");
ok($cpn->category eq "cat");
ok($cpn->package eq "pkg");

# invalid
ok(dies { Pkgcraft::Cpn->new("cat/pkg-1") });
ok(dies { Pkgcraft::Cpn->new("=cat/pkg-1") });

# invalid comparison types
ok(dies { $cpn == "cat/pkg" });

# missing string arg
ok(dies { Pkgcraft::Cpn->new() });

# valid comparisons
my $cpn1 = Pkgcraft::Cpn->new("a/b");
my $cpn2 = Pkgcraft::Cpn->new("a/c");
ok($cpn1 != $cpn2);
ok($cpn1 < $cpn2);

done_testing;
