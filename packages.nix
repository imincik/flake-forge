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
      repo.packages = [
        pkgs.hello
        pkgs.cowsay
      ];
    };
}
