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
        cfg = config.forge.apps;
      in
      {
        options = {
          forge = {
            apps = lib.mkOption {
              default = [ ];
              description = "List of applications.";
              type = lib.types.listOf (
                lib.types.submodule {
                  options = {
                    # General configuration
                    name = lib.mkOption {
                      type = lib.types.str;
                      default = "my-application";
                    };
                    description = lib.mkOption {
                      type = lib.types.str;
                      default = "";
                    };
                    version = lib.mkOption {
                      type = lib.types.str;
                      default = "1.0.0";
                    };
                    usage = lib.mkOption {
                      type = lib.types.str;
                      default = "";
                      description = "Application usage description in markdown format.";
                    };

                    # Programs shell configuration
                    programs = {
                      requirements = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [ ];
                      };
                    };

                    # Container configuration
                    containers = {
                      images = lib.mkOption {
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
                      composeFile = lib.mkOption {
                        type = lib.types.path;
                        description = "Relative path to a container compose file.";
                        example = "./compose.yaml";
                      };
                    };

                    # Virtual machine
                    vm = {
                      enable = lib.mkEnableOption ''
                        Virtual machine.
                      '';
                      name = lib.mkOption {
                        type = lib.types.str;
                        default = "nixos-vm";
                      };
                      requirements = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [ ];
                      };
                      config = {
                        system = lib.mkOption {
                          type = lib.types.attrsOf lib.types.anything;
                          default = { };
                          description = ''
                            NixOS system configuration.

                            See: https://search.nixos.org/options
                          '';
                          example = lib.literalExpression ''
                            {
                              services.postgresql.enabled = true;
                            }
                          '';
                        };
                        ports = lib.mkOption {
                          type = lib.types.listOf (lib.types.strMatching "^[0-9]*:[0-9]*$");
                          default = [ ];
                          description = ''
                            List of ports to forward from host system to VM.

                            Format: HOST_PORT:VM_PORT
                          '';
                          example = lib.literalExpression ''
                            [ "10022:22" "5432:5432" "8000:90" ]
                          '';
                        };
                      };
                    };
                  };
                }
              );
            };
          };
        };

        config =
          let
            shellBundle =
              app:
              let
                appDrv = (
                  pkgs.symlinkJoin {
                    name = "${app.name}-${app.version}";
                    paths = app.programs.requirements;
                  }
                );
              in
              # Passthru
              appDrv.overrideAttrs (_: {
                passthru = appPassthru app appDrv;
              });

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

            containerBundle =
              app:
              pkgs.linkFarm "${app.name}-${app.version}" (
                # Container images
                (map (image: {
                  name = "${image.name}.tar.gz";
                  path = buildImage image;
                }) app.containers.images)
                # Compose file
                ++ [
                  {
                    name = "compose.yaml";
                    path = pkgs.writeTextFile {
                      name = "compose.yaml";
                      text = builtins.readFile app.containers.composeFile;
                    };
                  }
                ]
              );

            nixosVm =
              app:
              let
                forwardPortsAttrs =
                  ports:
                  map (
                    port:
                    let
                      portSplit = lib.splitString ":" port;
                    in
                    {
                      from = "host";
                      host.port = lib.toInt (lib.elemAt portSplit 0);
                      guest.port = lib.toInt (lib.elemAt portSplit 1);
                    }
                  ) ports;

                vm = inputs.nixpkgs.lib.nixosSystem {
                  system = "x86_64-linux";
                  modules = [
                    (
                      { pkgs, ... }:
                      lib.recursiveUpdate {
                        imports = [ "${inputs.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix" ];
                        users.users.root.password = "root";
                        services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
                        services.openssh.settings.PasswordAuthentication = lib.mkForce true;
                        services.getty.autologinUser = "root";
                        environment.systemPackages = app.vm.requirements;
                        networking.hostName = app.vm.name;
                        networking.useDHCP = lib.mkForce true;
                        networking.firewall.enable = lib.mkForce false;
                        virtualisation.graphics = false;
                        virtualisation.memorySize = 1024 * 2;
                        virtualisation.diskSize = 1024 * 4;
                        virtualisation.forwardPorts = forwardPortsAttrs app.vm.config.ports;
                        system.stateVersion = "25.11";
                      } app.vm.config.system
                    )
                  ];
                };
              in
              vm.config.system.build.vm;

            appPassthru =
              # finalApp parameter is currently not used in this function
              app: finalApp:
              {
                containers = containerBundle app;
              }
              // lib.optionalAttrs app.vm.enable { vm = nixosVm app; };

            allApps = lib.listToAttrs (
              map (app: {
                name = "${app.name}";
                value = shellBundle app;
              }) cfg
            );
          in
          {
            packages = allApps;
          };
      }
    );
  };
}
