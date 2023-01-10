use Test2::V0;

use v5.30;
use strict;
use warnings;

use Pkgcraft::Eapi;

# test globals access
ok(keys %$EAPIS > keys %$EAPIS_OFFICIAL);

# verify objects are shared between $EAPIS_OFFICIAL and $EAPIS
foreach my $k (keys %$EAPIS_OFFICIAL) {
  is($EAPIS->{$k}, $EAPIS_OFFICIAL->{$k});
}

# verify $EAPI_LATEST reference
is($EAPIS->{$EAPI_LATEST}, $EAPI_LATEST);

is(Pkgcraft::Eapi->range("..2"), [$EAPIS->{0}, $EAPIS->{1}]);
is(Pkgcraft::Eapi->range("3..4"), [$EAPIS->{3}]);

done_testing;