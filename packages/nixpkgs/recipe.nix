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
      forge = {
        packages.nixpkgs = [
          pkgs.cowsay
          pkgs.gdal
          pkgs.jq
        ];
      };
    };
}
