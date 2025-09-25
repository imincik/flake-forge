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
                # General configuration
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
                mainProgram = lib.mkOption {
                  type = lib.types.str;
                  default = "my-program";
                  example = "hello";
                };

                # Source configuration
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

                # Build configuration
                build = {
                  plainBuilder = {
                    enable = lib.mkEnableOption ''
                      Plain builder.
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
                    configure = lib.mkOption {
                      type = lib.types.str;
                      default = "echo 'Configure phase'";
                    };
                    build = lib.mkOption {
                      type = lib.types.str;
                      default = "echo 'Build phase'";
                    };
                    check = lib.mkOption {
                      type = lib.types.str;
                      default = "echo 'Check phase'";
                    };
                    install = lib.mkOption {
                      type = lib.types.str;
                      default = "echo 'Install phase'";
                    };
                  };

                  standardBuilder = {
                    enable = lib.mkEnableOption ''
                      Standard builder.
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

                # Test configuration
                test = {
                  requirements = lib.mkOption {
                    type = lib.types.listOf lib.types.package;
                    default = [ ];
                  };
                  script = lib.mkOption {
                    type = lib.types.str;
                    default = ''
                      echo "Test script"
                    '';
                  };
                };
              };
            }
          );
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

            pkgPassthru = pkg: finalPkg: {
              test = pkgs.testers.runCommand {
                name = "${pkg.name}-test";
                buildInputs = [ finalPkg ] ++ pkg.test.requirements;
                script = pkg.test.script + "\ntouch $out";
              };
              image = pkgs.dockerTools.buildImage {
                name = "${pkg.name}";
                tag = pkg.version;
                copyToRoot = [
                  finalPkg
                ];
                config = {
                  Entrypoint = [ "${pkgs.bashInteractive}/bin/bash" ];
                };
              };
            };

            pkgMeta = pkg: {
              description = pkg.description;
              mainProgram = pkg.mainProgram;
            };

            plainBuilderPkgs = lib.listToAttrs (
              map (pkg: {
                name = pkg.name;
                value = pkgs.callPackage (
                  # Derivation start
                  { stdenv }:
                  stdenv.mkDerivation (finalAttrs: {
                    pname = pkg.name;
                    version = pkg.version;
                    src = pkgSource pkg;
                    nativeBuildInputs = pkg.build.plainBuilder.requirements.native;
                    buildInputs = pkg.build.plainBuilder.requirements.build;
                    configurePhase = pkg.build.plainBuilder.configure;
                    buildPhase = pkg.build.plainBuilder.build;
                    installPhase = pkg.build.plainBuilder.install;
                    checkPhase = pkg.build.plainBuilder.check;
                    doCheck = true;
                    doInstallCheck = true;
                    passthru = pkgPassthru pkg finalAttrs.finalPackage;
                    meta = pkgMeta pkg;
                  })
                  # Derivation end
                ) { };
              }) (lib.filter (p: p.build.plainBuilder.enable == true) cfg.packages)
            );

            standardBuilderPkgs = lib.listToAttrs (
              map (pkg: {
                name = pkg.name;
                value = pkgs.callPackage (
                  # Derivation start
                  { stdenv }:
                  stdenv.mkDerivation (finalAttrs: {
                    pname = pkg.name;
                    version = pkg.version;
                    src = pkgSource pkg;
                    nativeBuildInputs = pkg.build.standardBuilder.requirements.native;
                    buildInputs = pkg.build.standardBuilder.requirements.build;
                    passthru = pkgPassthru pkg finalAttrs.finalPackage;
                    meta = pkgMeta pkg;
                  })
                  # Derivation end
                ) { };
              }) (lib.filter (p: p.build.standardBuilder.enable == true) cfg.packages)
            );

          in
          (plainBuilderPkgs // standardBuilderPkgs)
          //
            # Add forge-config package
            {
              _forge-config = pkgs.writeTextFile {
                name = "forge-config.json";
                text = builtins.toJSON cfg;
              };
            };
      };
    };
}
