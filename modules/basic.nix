{ lib, ... }:

{
  perSystem =
    { config, pkgs, ... }:
    {
      options.flake-packages.packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Packages to expose as flake.packages";
      };

      config.packages = lib.listToAttrs (
        map (pkg: {
          name = pkg.pname;
          value = pkg;
        }) config.flake-packages.packages
      );
    };
}
