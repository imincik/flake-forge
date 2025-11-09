{
  inputs,
  config,
  lib,
  flake-parts-lib,
  ...
}:

let
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  options = {
    perSystem = mkPerSystemOption (
      { config, pkgs, ... }:
      let
        cfg = config.forge.packages;
      in
      {
        options = {
          forge = {
            packages = lib.mkOption {
              default = [ ];
              description = "List of packages.";
              type = lib.types.listOf (
                lib.types.submodule {
                  options = {
                    # General configuration
                    name = lib.mkOption {
                      type = lib.types.strMatching "^[a-z][a-z0-9-]*$";
                      default = "my-package";
                      description = ''
                        Package name.
                        Only lowercase letters and hyphens are allowed. Package name must start with letter.
                      '';
                    };
                    description = lib.mkOption {
                      type = lib.types.str;
                      default = "";
                      description = "Short package description.";
                    };
                    version = lib.mkOption {
                      type = lib.types.str;
                      default = "1.0.0";
                      description = "Package version.";
                    };
                    homePage = lib.mkOption {
                      type = lib.types.strMatching "^https?:\/\/.+$";
                      default = "";
                      description = "Home page URL.";
                    };
                    mainProgram = lib.mkOption {
                      type = lib.types.str;
                      default = "my-program";
                      example = "hello";
                      description = "Main executable name.";
                    };

                    # Source configuration
                    source = {
                      git = lib.mkOption {
                        type = lib.types.nullOr (lib.types.strMatching "^.*:.*/.*/.*$");
                        default = null;
                        example = "github:my-user/my-repo/v1.0.0";
                        description = "Git repository and version path.";
                      };
                      url = lib.mkOption {
                        type = lib.types.nullOr (lib.types.strMatching "^https?:\/\/.+$");
                        default = null;
                        example = "https://downloads.my-project/my-package-1.0.0.tar.gz";
                        description = "Source code tarball URL.";
                      };
                      hash = lib.mkOption {
                        type = lib.types.str;
                        default = "";
                        example = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
                        description = ''
                          Source code hash.

                          Leave hash value empty during first package build and replace it with suggested value.
                        '';
                      };
                    };

                    # Build configuration
                    build = {
                      plainBuilder = {
                        enable = lib.mkEnableOption "support for building packages using plain shell commands";
                        requirements = {
                          native = lib.mkOption {
                            type = lib.types.listOf lib.types.package;
                            default = [ ];
                            example = lib.literalExpression ''
                              [
                                pkgs.cmake
                                pkgs.ninja
                              ];
                            '';
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
                        enable = lib.mkEnableOption "support for building Makefile, Autotools and CMake (Meson, Ninja) based packages";
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

                      pythonAppBuilder = {
                        enable = lib.mkEnableOption "support for build Python applications";
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
                      };

                      # Other common builder options
                      extraDrvAttrs = lib.mkOption {
                        type = lib.types.attrsOf lib.types.anything;
                        default = { };
                        description = ''
                          Set extra Nix derivation attributes.
                          Expert option.
                        '';
                        example = lib.literalExpression ''
                          {
                            preConfigure = "export HOME=$(mktemp -d)"
                            postInstall = "rm $out/somefile.txt"
                          }
                        '';
                      };
                      debug = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = ''
                          Enable interactive package build environment for debugging.

                          Launch environment:
                          ```
                          mkdir dev && cd dev
                          nix develop .#<package>
                          ```

                          and follow instructions.
                        '';
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

                    # Development configuration
                    development = {
                      requirements = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [ ];
                      };
                      shellHook = lib.mkOption {
                        type = lib.types.str;
                        default = ''
                          echo -e "\nWelcome. This environment contains all dependencies required"
                          echo "to build this software from source."
                          echo
                          echo "Now, navigate to the source code directory and you are all set to"
                          echo "start hacking."
                        '';
                      };
                    };
                  };
                }
              );
            };
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
                devenv = pkgs.mkShell {
                  inputsFrom = [
                    finalPkg
                  ];
                  packages = pkg.development.requirements;
                  shellHook = pkg.development.shellHook;
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
                      // lib.optionalAttrs pkg.build.debug debugShellHookAttr
                    )
                    # Derivation end
                  ) { };
                }) (lib.filter (p: p.build.plainBuilder.enable == true) cfg)
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
                      // pkg.build.extraDrvAttrs
                      // lib.optionalAttrs pkg.build.debug debugShellHookAttr
                    )
                    # Derivation end
                  ) { };
                }) (lib.filter (p: p.build.standardBuilder.enable == true) cfg)
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
                      // pkg.build.extraDrvAttrs
                      // lib.optionalAttrs pkg.build.debug debugShellHookAttr
                    )
                    # Derivation end
                  ) { thePackage = value; };
                }) (lib.filter (p: p.build.pythonAppBuilder.enable == true) cfg)
              );
            in
            (plainBuilderPkgs // standardBuilderPkgs // pythonAppBuilderPkgs);
        };
      }
    );
  };
}
