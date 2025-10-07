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
            test =
              pkgs.testers.runNixOSTest {
                name = "${app.name}-test";
                nodes.machine =
                  { config, pkgs, ... }:
                  {
                    users.users.test = {
                      isNormalUser = true;
                      extraGroups = [ "wheel" ];
                    };
                    virtualisation.podman.enable = true;
                    environment.systemPackages = [
                      finalApp
                      pkgs.podman-compose
                    ];
                    system.stateVersion = "25.11";
                  };
                testScript = ''
                  machine.wait_for_unit("default.target")
                  machine.succeed("ping -c 4 8.8.8.8")
                  machine.succeed("""
                    # Load images
                    for image in ${finalApp}/*.tar.gz; do
                      podman load < $image
                    done
                    # Launch services
                    podman-compose --profile services --file ${finalApp}/compose.yaml up --detach
                  """)
                  machine.succeed("curl localhost:5000/init")
                '';
              }
              // {
                __noChroot = true;
              };
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
            # Test
            appDrv.overrideAttrs (old: {
              passthru = appPassthru app appDrv;
            });

          shellPackages = lib.listToAttrs (
            map (app: {
              name = "${app.name}-shell";
              value = shellBundle app;
            }) cfg
          );

          containerPackages = lib.listToAttrs (
            map (app: {
              name = "${app.name}-app";
              value = containerBundle app;
            }) cfg
          );
        in
        {
          packages = shellPackages // containerPackages;
        };
    };
}
