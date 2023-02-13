use Test2::V0;
use TOML::Tiny qw(from_toml);

use v5.30;
use strict;
use warnings;
no warnings qw(experimental);

use Pkgcraft::Version;

# load test data
open my $fh, '<', 'testdata/toml/version.toml' or die "Can't open file: $!";
my $toml = do { local $/; <$fh> };
my ($VERSION_DATA, $err) = from_toml($toml);
unless ($VERSION_DATA) {
  die "Error parsing toml: $err";
}

my $ver = Pkgcraft::Version->new("1-r2");
ok($ver->revision eq "2");
ok($ver eq "1-r2");

# missing string arg
ok(dies { Pkgcraft::Version->new() });
ok(dies { Pkgcraft::VersionWithOp->new() });

# invalid versions
ok(dies { Pkgcraft::Version->new("r2") });
ok(dies { Pkgcraft::VersionWithOp->new("1-r2") });

# invalid comparisons
ok(dies { $ver == "1-r2" });
ok(dies { Pkgcraft::VersionWithOp->new(">1-r2") == ">1-r2" });

# version comparisons
foreach my $str (@{$VERSION_DATA->{"compares"}}) {
  my ($s1, $op, $s2) = split ' ', $str;
  my $v1 = Pkgcraft::Version->new($s1);
  my $v2 = Pkgcraft::Version->new($s2);
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
foreach my $hash (@{$VERSION_DATA->{"sorting"}}) {
  my %data = %$hash;
  my @reversed = reverse @{$data{sorted}};
  my @sorted
    = sort { Pkgcraft::Version->new($a) <=> Pkgcraft::Version->new($b) } @reversed;

  # equal versions aren't sorted so reversing should restore the original order
  if ($data{equal}) {
    @sorted = reverse @sorted;
  }

  is(\@sorted, $data{sorted});
}

# TODO: use shared intersects test data
# intersects
my $v1 = Pkgcraft::Version->new("1.0.2");
my $v2 = Pkgcraft::Version->new("1.0.2-r0");
ok($v1->intersects($v2));
$v1 = Pkgcraft::Version->new("0");
$v2 = Pkgcraft::Version->new("1");
ok(!$v1->intersects($v2));
$v1 = Pkgcraft::Version->new("0");
$v2 = Pkgcraft::VersionWithOp->new("=0*");
ok($v1->intersects($v2));

done_testing;
