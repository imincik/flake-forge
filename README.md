# Flake Forge

**WARNING: this sofware is currently in alpha state.**

The friendly software distribution system with Nix super powers.


## Features

* Build process configuration using simple (JSON like) language
* Out-of-box container image output
* [Web UI](https://imincik.github.io/flake-forge)
* Simple for self hosting
* Not hiding Nix super powers


## Packaging workflow

1. Create a new package recipe file in `packages/<my-package>/recipe.nix` and
   add it to git. Check out existing examples in [packages](packages) directory.

2. Test build

```bash
nix build .#my-package
```

3. Publish package by merging the recipe file


## TODOs

* Many more builder configuration options
* Configuration options for container images

