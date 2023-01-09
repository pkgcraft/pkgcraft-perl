[![CI](https://github.com/pkgcraft/pkgcraft-perl/workflows/CI/badge.svg)](https://github.com/pkgcraft/pkgcraft-perl/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/pkgcraft/pkgcraft-perl/branch/main/graph/badge.svg)](https://codecov.io/gh/pkgcraft/pkgcraft-perl)

# pkgcraft-perl

Perl bindings for pkgcraft.

## Install

To install this module use the following commands:

```
perl Makefile.PL
make
make test
make install
```

## Runtime dependencies

- [pkgcraft-c](https://github.com/pkgcraft/pkgcraft/tree/main/crates/pkgcraft-c)
- FFI::CheckLib
- FFI::Platypus
