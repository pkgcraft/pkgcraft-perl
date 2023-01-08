package Pkgcraft::Eapi;

use Pkgcraft;

use Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(Eapi);

$ffi->type('opaque' => 'Eapi');
