{ inputs, lib, ... }:

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
                  git = lib.mkOption {
                    type = lib.types.nullOr (lib.types.strMatching "^.*:.*/.*/.*$");
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
                build =
                  let
                    extraDrvAttrsOption = lib.mkOption {
                      type = lib.types.attrsOf lib.types.anything;
                      default = { };
                      description = ''
                        Expert option.

                        Set extra Nix derivation attributes.
                      '';
                      example = lib.literalExpression ''
                        {
                          preConfigure = "export HOME=$(mktemp -d)"
                          postInstall = "rm $out/somefile.txt"
                        }
                      '';
                    };

                    buildDebugOption = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = ''
                        Enable interactive package build environment for
                        debugging.

                        Launch environment:

                        ```
                        mkdir dev && cd dev
                        nix develop .#<package>
                        ```

                        and follow instructions.
                      '';
                    };
                  in
                  {
                    plainBuilder = {
                      enable = lib.mkEnableOption ''
                        Plain builder.
                      '';
                      debug = buildDebugOption;
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
                      debug = buildDebugOption;
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
                      extraDrvAttrs = extraDrvAttrsOption;
                    };

                    pythonAppBuilder = {
                      enable = lib.mkEnableOption ''
                        Python application builder.
                      '';
                      debug = buildDebugOption;
                      requirements = {
                        build-system = lib.mkOption {
                          type = lib.types.listOf lib.types.package;
                          default = [ ];
                        };
                        dependencies = lib.mkOption {
                          type = lib.types.listOf lib.types.package;
                          default = [ ];
                        };
                      };
                      extraDrvAttrs = extraDrvAttrsOption;
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
              let
                gitForges = {
                  # forge = fetchFunction
                  github = pkgs.fetchFromGitHub;
                  gitlab = pkgs.fetchFromGitLab;
                };
              in
              pkg:
              assert
                (pkg.source.git == null && pkg.source.url == null)
                -> throw "'source.git' or 'source.url' must be defined for ${pkg.name}";
              # By default, try to use git
              if pkg.source.git != null then
                let
                  gitForge = lib.elemAt (lib.splitString ":" pkg.source.git) 0;
                  gitParams = lib.splitString "/" pkg.source.git;
                in
                gitForges.${gitForge} {
                  owner = lib.removePrefix "${gitForge}:" (lib.lists.elemAt gitParams 0);
                  repo = lib.lists.elemAt gitParams 1;
                  rev = lib.lists.elemAt gitParams 2;
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

            debugShellHookAttr = {
              shellHook = "source ${inputs.nix-utils}/nix-develop-interactive.bash";
            };

            plainBuilderPkgs = lib.listToAttrs (
              map (pkg: {
                name = pkg.name;
                value = pkgs.callPackage (
                  # Derivation start
                  { stdenv }:
                  stdenv.mkDerivation (
                    finalAttrs:
                    {
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
                    }
                    // lib.optionalAttrs pkg.build.plainBuilder.debug debugShellHookAttr
                  )
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
                  stdenv.mkDerivation (
                    finalAttrs:
                    {
                      pname = pkg.name;
                      version = pkg.version;
                      src = pkgSource pkg;
                      nativeBuildInputs = pkg.build.standardBuilder.requirements.native;
                      buildInputs = pkg.build.standardBuilder.requirements.build;
                      passthru = pkgPassthru pkg finalAttrs.finalPackage;
                      meta = pkgMeta pkg;
                    }
                    // pkg.build.standardBuilder.extraDrvAttrs
                    // lib.optionalAttrs pkg.build.standardBuilder.debug debugShellHookAttr
                  )
                  # Derivation end
                ) { };
              }) (lib.filter (p: p.build.standardBuilder.enable == true) cfg.packages)
            );

            pythonAppBuilderPkgs = lib.listToAttrs (
              map (pkg: rec {
                name = pkg.name;
                value = pkgs.callPackage (
                  # Derivation start
                  # buildPythonPackage doesn't support finalAttrs function.
                  # Passing thePackage to derivation is used as workaround.
                  { stdenv, thePackage }:
                  pkgs.python3Packages.buildPythonApplication (
                    {
                      pname = pkg.name;
                      version = pkg.version;
                      format = "pyproject";
                      src = pkgSource pkg;
                      build-system = pkg.build.pythonAppBuilder.requirements.build-system;
                      dependencies = pkg.build.pythonAppBuilder.requirements.dependencies;
                      passthru = pkgPassthru pkg thePackage;
                      meta = pkgMeta pkg;
                    }
                    // pkg.build.pythonAppBuilder.extraDrvAttrs
                    // lib.optionalAttrs pkg.build.pythonAppBuilder.debug debugShellHookAttr
                  )
                  # Derivation end
                ) { thePackage = value; };
              }) (lib.filter (p: p.build.pythonAppBuilder.enable == true) cfg.packages)
            );
          in
          (plainBuilderPkgs // standardBuilderPkgs // pythonAppBuilderPkgs);
      };
    };
}
