{ inputs, ... }:

{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    {
      flake-packages.packages = [
        pkgs.hello
        pkgs.cowsay
      ];
    };
}
