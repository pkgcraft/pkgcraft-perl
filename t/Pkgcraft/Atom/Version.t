use Test2::V0;

use Pkgcraft::Atom;

my $ver = Pkgcraft::Atom::Version->new("1-r2");
ok($ver->revision eq "2");
ok($ver eq "1-r2");

done_testing;
