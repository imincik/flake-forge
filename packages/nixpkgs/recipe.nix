{ inputs, ... }:

{
  debug = true;

  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    {
      repo = {
        packages.nixpkgs = [
          pkgs.cowsay
          pkgs.gdal
          pkgs.jq
        ];
      };
    };
}
