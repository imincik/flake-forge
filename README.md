# Nix Forge

**WARNING: this sofware is currently in alpha state.**

The friendly software distribution system with Nix super powers.


## Features

* Build process configuration using human readable language
  (inspired by [conda-forge](https://conda-forge.org/))

* Outputs:
  * Nix packages for Linux (and Mac in a future)
  * Container images for packages and apps
  * Development environments for packages
  * NixOS virtual machines for apps

* [Web UI](https://imincik.github.io/nix-forge)

* Great for self hosting


## Packaging workflow

1. Create a new package recipe file in
   `outputs/packages/<package>/recipe.nix` and add it to git.

1. Build package

```bash
nix build .#<package> -L
```

1. Inspect and test build output in `./result` directory

1. Submit PR and wait for tests

1. Publish package by merging the PR

### Configuration options

* [Packages](ui/src/docs/options-packages.html)

* [Apps](ui/src/docs/options-apps.html)

### Recipe examples

* [Package recipe examples](outputs/packages)

* [Application recipe examples](outputs/apps)

### Package debugging

Set `build.<builder>.debug = true` and launch interactive package build
environment by running

```bash
mkdir dev && cd dev
nix develop .#<package>
```

and follow instructions.

### Package tests

* Run package test

```bash
nix build .#<package>.test -L
```

## TODOs

* CI checks and workflows (dependencies updates, ...)

* Many more language speciffic builders and configuration options

