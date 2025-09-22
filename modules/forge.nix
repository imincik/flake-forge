{ lib, ... }:

{
  perSystem =
    { config, pkgs, ... }:

    let
      cfg = config.forge;
    in
    {
      options.forge = {

        packages = lib.mkOption {
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                # General options
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

                # Package build configuration
                build = {
                  defaultBuilder = {
                    enable = lib.mkEnableOption ''
                      Default builder.
                    '';
                    requirements = {
                      native = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [ ];
                      };
                      build = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [ ];
                      };
                    };
                  };
                };
              };
            }
          );
        };

        nixpkgs = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Nixpkgs packages to expose as flake.packages";
        };
      };

      config.packages =
        let
          defaultBuilderPkgs = lib.listToAttrs (
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
                  nativeBuildInputs = pkg.build.defaultBuilder.requirements.native;
                  buildInputs = pkg.build.defaultBuilder.requirements.build;
                }
                # Derivation end
              ) { };
            }) (lib.filter (p: p.build.defaultBuilder.enable == true) cfg.packages)
          );

          nixpkgsPkgs = lib.listToAttrs (
            map (pkg: {
              name = pkg.pname;
              value = pkg;
            }) cfg.nixpkgs
          );

        in
        (defaultBuilderPkgs // nixpkgsPkgs)
        //
          # Add forge-forge-ui package
          {
            flake-forge-ui = pkgs.callPackage ../ui/package.nix {
              forgeConfig = cfg;
            };
          };
    };
}
