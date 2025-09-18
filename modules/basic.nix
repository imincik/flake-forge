{ lib, ... }:

{
  perSystem =
    { config, pkgs, ... }:

    let
      cfg = config.repo;
    in
    {
      options.repo = {
        packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Packages to expose as flake.packages";
        };
      };

      config.packages = lib.listToAttrs (
        map (pkg: {
          name = pkg.pname + "-custom";
          value = pkg.overrideAttrs (prev: {
            pname = prev.pname + "-custom";
          });
        }) cfg.packages
      );
    };
}
