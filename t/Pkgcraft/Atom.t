use strict;
use warnings;

use Test::More;
BEGIN { use_ok('Pkgcraft::Atom') }

my $cpv = Pkgcraft::Cpv->new("cat/pkg-1");
ok($cpv->category eq "cat");
ok($cpv->package eq "pkg");
ok($cpv->version eq "1");
ok($cpv->revision eq "0");
ok($cpv eq "cat/pkg-1");
ok(sprintf("%s", $cpv) eq "cat/pkg-1");

my $atom = Pkgcraft::Atom->new("cat/pkg");
ok($atom->category eq "cat");
ok($atom->package eq "pkg");
is($atom->version,  undef);
is($atom->revision, undef);
is($atom->slot,     undef);
is($atom->subslot,  undef);
is($atom->repo,     undef);
is($atom->use,      undef);
ok($atom->cpv eq "cat/pkg");
ok($atom eq "cat/pkg");
ok(sprintf("%s", $atom) eq "cat/pkg");

$atom = Pkgcraft::Atom->new("cat/pkg[u1,u2]");
my @use = $atom->use;
my @foo = qw(u1 u2);
is_deeply(\@use, \@foo);

done_testing();
