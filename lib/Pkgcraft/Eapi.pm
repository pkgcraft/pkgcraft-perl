package Pkgcraft::Eapi;

use v5.30;
use strict;
use warnings;

use Pkgcraft;

use Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(Eapi);

$ffi->type('opaque' => 'Eapi');
