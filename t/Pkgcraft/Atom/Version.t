use Test2::V0;
use TOML::Tiny qw(from_toml);

use v5.30;
use strict;
use warnings;
no warnings qw(experimental);

use Pkgcraft::Atom::Version;

# load test data
open my $fh, '<', 'testdata/toml/version.toml' or die "Can't open file: $!";
my $toml = do { local $/; <$fh> };
my ($VERSION_DATA, $err) = from_toml($toml);
unless ($VERSION_DATA) {
  die "Error parsing toml: $err";
}

my $ver = Pkgcraft::Atom::Version->new("1-r2");
ok($ver->revision eq "2");
ok($ver eq "1-r2");

# missing string arg
ok(dies { Pkgcraft::Atom::Version->new() });
ok(dies { Pkgcraft::Atom::VersionWithOp->new() });

# invalid versions
ok(dies { Pkgcraft::Atom::Version->new("r2") });
ok(dies { Pkgcraft::Atom::VersionWithOp->new("1-r2") });

# invalid comparisons
ok(dies { $ver == "1-r2" });
ok(dies { Pkgcraft::Atom::VersionWithOp->new(">1-r2") == ">1-r2" });

# version comparisons
foreach my $str (@{$VERSION_DATA->{"compares"}}) {
  my ($s1, $op, $s2) = split ' ', $str;
  my $v1 = Pkgcraft::Atom::Version->new($s1);
  my $v2 = Pkgcraft::Atom::Version->new($s2);
  given ($op) {
    when ("<") { ok($v1 < $v2, $str) }
    when ("<=") { ok($v1 <= $v2, $str) }
    when ("==") { ok($v1 == $v2, $str) }
    when ("!=") { ok($v1 != $v2, $str) }
    when (">=") { ok($v1 >= $v2, $str) }
    when (">") { ok($v1 > $v2, $str) }
    default { die "unknown operator: $op" }
  }
}

# version sorting
foreach my $arrays (@{$VERSION_DATA->{"sorting"}}) {
  my ($unsorted, $expected) = @$arrays;
  my @sorted
    = sort { Pkgcraft::Atom::Version->new($a) <=> Pkgcraft::Atom::Version->new($b) }
    @$unsorted;
  is(\@sorted, $expected);
}

done_testing;
