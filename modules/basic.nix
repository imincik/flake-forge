{ lib, ... }:

{
  perSystem =
    { config, pkgs, ... }:

    let
      cfg = config.repo;
    in
    {
      options.repo = {
        enable = lib.mkEnableOption "enable repo";

        packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Packages to expose as flake.packages";
        };
      };

      config.packages = lib.mkIf cfg.enable (lib.listToAttrs (
        map (pkg: {
          name = pkg.pname + "-custom";
          value = pkg.overrideAttrs (prev: {
            pname = prev.pname + "-custom";
          });
        }) cfg.packages
      ));
    };
}
