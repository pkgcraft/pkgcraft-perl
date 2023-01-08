use strict;
use warnings;

use Test::More;
BEGIN { use_ok('Pkgcraft::Atom') }

my $cpv = Pkgcraft::Cpv->new("cat/pkg-1");
ok($cpv->category eq "cat");
ok($cpv->package eq "pkg");
ok($cpv->version->stringify eq "1");
ok($cpv->stringify eq "cat/pkg-1");
ok(sprintf("%s", $cpv) eq "cat/pkg-1");

my $atom = Pkgcraft::Atom->new("cat/pkg");
ok($atom->category eq "cat");
ok($atom->package eq "pkg");
is($atom->version, undef);
is($atom->slot,    undef);
is($atom->subslot, undef);
ok($atom->stringify eq "cat/pkg");
ok(sprintf("%s", $atom) eq "cat/pkg");

done_testing();
