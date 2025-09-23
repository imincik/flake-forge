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
                homePage = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                };
                source = {
                  github = lib.mkOption {
                    type = lib.types.nullOr (lib.types.strMatching "^.*/.*/.*$");
                    default = null;
                    example = "my-user/my-repo/v1.0.0";
                  };
                  url = lib.mkOption {
                    type = lib.types.nullOr (lib.types.strMatching "^.*://.*");
                    default = null;
                    example = "https://downloads.my-project/my-package-1.0.0.tar.gz";
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

      config = {
        packages =
          let
            pkgSource =
              pkg:
              assert
                (pkg.source.github == null && pkg.source.url == null)
                -> throw "'source.github' or 'source.url' must be defined for ${pkg.name}";
              # By default, try to use github
              if pkg.source.github != null then
                let
                  ghParams = lib.splitString "/" pkg.source.github;
                in
                pkgs.fetchFromGitHub {
                  owner = lib.lists.elemAt ghParams 0;
                  repo = lib.lists.elemAt ghParams 1;
                  rev = lib.lists.elemAt ghParams 2;
                  hash = pkg.source.hash;
                }
              # Fallback to tarball dowload
              else
                pkgs.fetchurl {
                  url = pkg.source.url;
                  hash = pkg.source.hash;
                };

            defaultBuilderPkgs = lib.listToAttrs (
              map (pkg: {
                name = pkg.name;
                value = pkgs.callPackage (
                  # Derivation start
                  { stdenv }:
                  stdenv.mkDerivation {
                    pname = pkg.name;
                    version = pkg.version;
                    src = pkgSource pkg;
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
            # Add forge-config and forge-ui packages
            rec {
              forge-config = pkgs.writeTextFile {
                name = "forge-config.json";
                text = builtins.toJSON cfg;
              };

              forge-ui = pkgs.callPackage ../../ui/package.nix {
                inherit forge-config;
              };
            };
      };
    };
}
