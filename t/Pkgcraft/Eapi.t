use Test2::V0;

use v5.30;
use strict;
use warnings;

use Pkgcraft::Eapi;

# verify $EAPI_LATEST reference
is($EAPI_LATEST, EAPIS($EAPI_LATEST));

# EAPI feature support
ok(!EAPIS(0)->has("slot_deps"));
ok(EAPIS(1)->has("slot_deps"));
ok($EAPI_LATEST->has("slot_deps"));
ok(!$EAPI_LATEST->has("nonexistent"));

# test globals access
ok(keys %{EAPIS()} > keys %{EAPIS_OFFICIAL()});

# verify objects are shared between EAPIS_OFFICIAL and EAPIS
foreach my $k (keys %{EAPIS_OFFICIAL()}) {
  is(EAPIS($k), EAPIS_OFFICIAL($k));
}

is(Pkgcraft::Eapi::range("..2"), [EAPIS(0), EAPIS(1)]);
is(Pkgcraft::Eapi::range("3..4"), [EAPIS(3)]);
ok(dies { Pkgcraft::Eapi::range("..9999") });

# comparisons
ok(EAPIS(0) == EAPIS_OFFICIAL(0));
ok(EAPIS(1) > EAPIS(0));
ok(dies { EAPIS(0) == "0" });
ok(EAPIS(0) eq "0");

done_testing;
