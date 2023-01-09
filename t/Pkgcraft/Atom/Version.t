use strict;
use warnings;

use Test::More;
BEGIN { use_ok('Pkgcraft::Atom::Version') }

my $ver = Pkgcraft::Atom::Version->new("1-r2");
ok($ver->revision eq "2");
ok($ver eq "1-r2");

done_testing();
