# Flake Forge

**WARNING: this sofware is currently in alpha state.**

The friendly software distribution system with Nix super powers.


## Features

* Build process configuration using simple
  ([conda-forge](https://conda-forge.org/) style) language

* Outputs:
  * Nix packages
  * Package container images
  * Multi-container application images

* [Web UI](https://imincik.github.io/flake-forge)

* Simple for self hosting


## Packaging workflow

1. Create a new package recipe file in
   `outputs/packages/<my-package>/recipe.nix` and add it to git.

1. Test build

```bash
nix build .#my-package
```

1. Inspect and test build output in `./result` directory

1. Submit PR and wait for tests

1. Publish package by merging the PR

### Examples

* [Package recipe examples](outputs/packages)

* [Application recipe examples](outputs/apps)

### Debugging

Set `build.<builder>.debug = true` and launch interactive package build
environment by running

```
mkdir dev && cd dev
nix develop .#<package>
```

and follow instructions.


## TODOs

* CI checks and workflows (dependencies updates, ...)

* Many more builder configuration options

