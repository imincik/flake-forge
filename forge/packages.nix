{ inputs, ... }:

{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    {
      packages = {
        _forge-config = pkgs.writeTextFile {
          name = "forge-config.json";
          text = builtins.toJSON config.forge;
        };

        _forge-ui = pkgs.callPackage ../ui/package.nix {
          inherit (config.packages) _forge-config;
        };
      };
    };
}
