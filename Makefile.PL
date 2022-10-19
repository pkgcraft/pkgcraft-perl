use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Pkgcraft',
    VERSION_FROM      => 'lib/Pkgcraft.pm',
    PREREQ_PM         => {
        'FFI::CheckLib' => '0.31',
        'FFI::Platypus' => '2.00',
    },
    MIN_PERL_VERSION  => '5.030',
    ABSTRACT_FROM     => 'lib/Pkgcraft.pod',
    AUTHOR            => 'Tim Harder <radhermit@gmail.com>',
    LICENSE           => 'perl',
    test => {RECURSIVE_TEST_FILES=>1},
);
