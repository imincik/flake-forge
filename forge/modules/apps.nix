{ lib, ... }:

{
  perSystem =
    { config, pkgs, ... }:

    let
      cfg = config.forge.apps;
    in
    {
      options.forge = {
        apps = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submoduleWith {
              modules = [
                (
                  { name, ... }:
                  {
                    config.name = name; # set internal option
                    options = {
                      # General configuration
                      name = lib.mkOption {
                        type = lib.types.str;
                        internal = true;
                      };
                      description = lib.mkOption {
                        type = lib.types.str;
                        default = "";
                      };
                      version = lib.mkOption {
                        type = lib.types.str;
                        default = "1.0.0";
                      };

                      # Programs shell configuration
                      programs = {
                        requirements = lib.mkOption {
                          type = lib.types.listOf lib.types.package;
                          default = [ ];
                        };
                      };

                      # Container configuration
                      containers = lib.mkOption {
                        type = lib.types.listOf (
                          lib.types.submodule {
                            options = {
                              name = lib.mkOption {
                                type = lib.types.str;
                                default = "app-container";
                              };
                              requirements = lib.mkOption {
                                type = lib.types.listOf lib.types.package;
                                default = [ ];
                              };
                              config = {
                                CMD = lib.mkOption {
                                  type = lib.types.listOf lib.types.str;
                                  default = [ ];
                                };
                              };
                            };
                          }
                        );
                      };

                      # Compose configuration
                      composeFile = lib.mkOption {
                        type = lib.types.path;
                        description = "Relative path to a container compose file.";
                        example = "./compose.yaml";
                      };
                    };
                  }
                )
              ];
            }
          );
        };
      };

      config =
        let
          buildImage =
            image:
            pkgs.dockerTools.buildImage {
              name = image.name;
              tag = "latest";
              copyToRoot = pkgs.buildEnv {
                name = "image-root";
                paths = image.requirements;
                pathsToLink = [ "/bin" ];
              };
              config = {
                Cmd = image.config.CMD;
              };
            };

          shellBundle =
            app:
            pkgs.symlinkJoin {
              name = "${app.name}-${app.version}";
              paths = app.programs.requirements;
            };

          appPassthru = app: finalApp: {
            # finalApp parameter is currently not used in this function
            programs = shellBundle app;
          };

          containerBundle =
            app:
            let
              appDrv = (
                pkgs.linkFarm "${app.name}-${app.version}" (
                  # Container images
                  (map (image: {
                    name = "${image.name}.tar.gz";
                    path = buildImage image;
                  }) app.containers)
                  # Compose file
                  ++ [
                    {
                      name = "compose.yaml";
                      path = pkgs.writeTextFile {
                        name = "compose.yaml";
                        text = builtins.readFile app.composeFile;
                      };
                    }
                  ]
                )
              );
            in
            # Passthru
            appDrv.overrideAttrs (_: {
              passthru = appPassthru app appDrv;
            });

          containerPackages = lib.mapAttrs (name: app: containerBundle app) cfg;
        in
        {
          packages = containerPackages;
        };
    };
}
