use Test2::V0;

use v5.30;
use strict;
use warnings;

use Pkgcraft::Eapi;

# verify EAPI aliases
is($EAPI_LATEST_OFFICIAL, EAPIS($EAPI_LATEST_OFFICIAL));
is($EAPI_LATEST, EAPIS($EAPI_LATEST));

# EAPI feature support
ok($EAPI_LATEST_OFFICIAL->has("UsevTwoArgs"));
ok(!$EAPI_LATEST_OFFICIAL->has("nonexistent"));
ok(dies { $EAPI_LATEST_OFFICIAL->has() });

# test globals access
ok(keys %{EAPIS()} > keys %{EAPIS_OFFICIAL()});

# verify objects are shared between EAPIS_OFFICIAL and EAPIS
foreach my $k (keys %{EAPIS_OFFICIAL()}) {
  is(EAPIS($k), EAPIS_OFFICIAL($k));
}

is(Pkgcraft::Eapi::range("..6"), [EAPIS(5)]);
is(Pkgcraft::Eapi::range("7..8"), [EAPIS(7)]);
ok(dies { Pkgcraft::Eapi::range("..9999") });
ok(dies { Pkgcraft::Eapi::range() });

# comparisons
ok(EAPIS(8) == EAPIS_OFFICIAL(8));
ok(EAPIS(8) > EAPIS(7));
ok(dies { EAPIS(8) == "8" });
ok(EAPIS(8) eq "8");

done_testing;
