{ inputs, ... }:

{
  # debug = true;

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

        _forge-packages = pkgs.symlinkJoin {
          name = "forge-packages";
          paths = lib.attrValues (lib.filterAttrs (n: v: !lib.hasPrefix "_forge" n) config.packages);
        };

        _forge-ui = pkgs.callPackage ../ui/package.nix {
          inherit (config.packages) _forge-config;
        };
      };
    };
}
