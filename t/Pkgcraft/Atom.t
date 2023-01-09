use Test2::V0;
use TOML::Tiny qw(from_toml);

use Pkgcraft::Atom;

# load atom test data
open my $fh, '<', 'testdata/toml/atom.toml' or die "Can't open file: $!";
my $toml = do { local $/; <$fh> };
my ($ATOM_DATA, $err) = from_toml($toml);
unless ($ATOM_DATA) {
  die "Error parsing toml: $err";
}

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

# invalid atoms
foreach my $str (@{$ATOM_DATA->{"invalid"}}) {
  like(
    dies { Pkgcraft::Atom->new($str) },
    qr/invalid atom: \Q$str\E/,
    "invalid atom: $str"
  );
}

# equivalent atoms with unequal strings
foreach my $str (@{$ATOM_DATA->{"compares"}}) {
  my ($s1, $op, $s2) = split ' ', $str;
  my $a1 = Pkgcraft::Atom->new($s1);
  my $a2 = Pkgcraft::Atom->new($s2);
  ok($a1 == $a2);
  ok($a1 ne $a2);
}

done_testing;
