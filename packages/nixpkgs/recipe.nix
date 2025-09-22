{ inputs, ... }:

{
  # debug = true;

  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    {
      forge.nixpkgs = [
        pkgs.cowsay
        pkgs.jq
      ];
    };
}
