use Test2::V0;

use Pkgcraft::Atom;

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
is($atom->version,  undef);
is($atom->revision, undef);
ok($atom->cpn eq "cat/pkg");
is($atom->blocker, undef);
is($atom->slot,    undef);
is($atom->subslot, undef);
is($atom->slot_op, undef);
is($atom->repo,    undef);
is($atom->use,     undef);
ok($atom->cpv eq "cat/pkg");
ok($atom eq "cat/pkg");
ok(sprintf("%s", $atom) eq "cat/pkg");

$atom = Pkgcraft::Atom->new("!cat/pkg[u1,u2]");
is($atom->blocker, Pkgcraft::Atom->BLOCKER_WEAK);
is($atom->use,     ["u1", "u2"]);

$atom = Pkgcraft::Atom->new("cat/pkg:1=");
ok($atom->slot eq "1");
is($atom->slot_op, Pkgcraft::Atom->SLOT_OPERATOR_EQUAL);

done_testing;
