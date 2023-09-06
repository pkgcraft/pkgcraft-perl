use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Pkgcraft',
    AUTHOR            => 'Tim Harder <radhermit@gmail.com>',
    LICENSE           => 'perl',
    VERSION_FROM      => 'lib/Pkgcraft.pm',
    PREREQ_PM         => {
        'FFI::CheckLib' => '0.31',
        'FFI::Platypus' => '2.08',
    },
    TEST_REQUIRES => {
        'Test2::V0' => '0.000155',
        'TOML::Tiny' => '0.16',
    },
    MIN_PERL_VERSION  => '5.30.0',
    ABSTRACT_FROM     => 'lib/Pkgcraft.pod',
    test => {RECURSIVE_TEST_FILES=>1},
);
