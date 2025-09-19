{ lib, ... }:

{
  perSystem =
    { config, pkgs, ... }:

    let
      cfg = config.forge;
    in
    {
      options.forge = {
        packages = {
          builders = {
            default = lib.mkOption {
              type = lib.types.listOf (
                lib.types.submodule {
                  options = {
                    name = lib.mkOption {
                      type = lib.types.str;
                      default = "my-package";
                    };
                    description = lib.mkOption {
                      type = lib.types.str;
                      default = "";
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
                    requirements = {
                      host = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [ ];
                      };
                      build = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [ ];
                      };
                    };
                  };
                }
              );
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
          builderDefault = lib.listToAttrs (
            map (pkg: {
              name = pkg.name;
              value = pkgs.callPackage (
                # Derivation start
                { stdenv, fetchurl }:
                stdenv.mkDerivation {
                  pname = pkg.name;
                  version = pkg.version;
                  src = fetchurl {
                    url = pkg.source.url;
                    hash = pkg.source.hash;
                  };
                  nativeBuildInputs = pkg.requirements.host;
                  buildInputs = pkg.requirements.build;
                }
                # Derivation end
              ) { };
            }) cfg.packages.builders.default
          );

          packagesNixpkgs = lib.listToAttrs (
            map (pkg: {
              name = pkg.pname;
              value = pkg;
            }) cfg.packages.nixpkgs
          );

        in
        (packagesNixpkgs // builderDefault)
        //
          # forge-config package
          {
            forge-config = pkgs.writeTextFile {
              name = "forge-config.json";
              text = builtins.toJSON cfg;
            };
          };
    };
}
