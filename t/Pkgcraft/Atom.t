use strict;
use warnings;

use Test::More;
BEGIN { use_ok('Pkgcraft::Atom') }

my $cpv = Pkgcraft::Cpv->new("cat/pkg-1");
ok($cpv->category() eq "cat");
ok($cpv->package() eq "pkg");

my $atom = Pkgcraft::Atom->new("cat/pkg");
ok($atom->category() eq "cat");
ok($atom->package() eq "pkg");
is($atom->slot(),    undef);
is($atom->subslot(), undef);

done_testing();
