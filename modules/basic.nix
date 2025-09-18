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

        packages = {
          builders = {
            default = {
              name = lib.mkOption {
                type = lib.types.str;
                default = "my-package";
              };
              version = lib.mkOption {
                type = lib.types.str;
                default = "1.0.0";
              };
              source = {
                url = lib.mkOption {
                  type = lib.types.str;
                };
                hash = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                };
              };
            };
          };

          nixpkgs = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
            description = "Nixpkgs packages to expose as flake.packages";
          };
        };
      };

      config.packages =
        let
          builderDefault = pkgs.callPackage (
            { stdenv, fetchurl }:
            stdenv.mkDerivation {
              pname = cfg.packages.builders.default.name;
              version = cfg.packages.builders.default.version;
              src = fetchurl {
                url = cfg.packages.builders.default.source.url;
                hash = cfg.packages.builders.default.source.hash;
              };
              buildInputs = [ ];
            }
          ) { };

          allPackages = lib.listToAttrs (
            map (pkg: {
              name = pkg.pname;
              value = pkg.overrideAttrs (prev: {
                pname = prev.pname;
              });
            }) (cfg.packages.nixpkgs ++ [ builderDefault ])
          );
        in

        lib.mkIf cfg.enable allPackages;
    };
}
