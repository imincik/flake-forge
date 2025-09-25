# Flake Forge

**WARNING: this sofware is currently in alpha state.**

The friendly software distribution system with Nix super powers.


## Features

* Software build process configuration using simple
  ([conda-forge](https://conda-forge.org/) style) language

* Outputs:
  * Nix packages
  * Out-of-box package container images
  * Configurable multi-container application images

* [Web UI](https://imincik.github.io/flake-forge)

* Simple for self hosting


## Packaging workflow

1. Create a new package recipe file in `outputs/<my-package>/recipe.nix` and
   add it to git.

1. Test build

```bash
nix build .#my-package
```

1. Inspect and test build output in `./result` directory

1. Submit PR and wait for tests

1. Publish package by merging the PR

### Examples

Check out existing package recipe examples in [outputs](outputs) directory.


## TODOs

* CI checks and workflows (dependencies updates, ...)

* Many more builder configuration options

* Multi-container application images

