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
        _forge-ui = pkgs.callPackage ../ui/package.nix {
          inherit (config.packages) _forge-config;
        };

        _forge-packages = pkgs.symlinkJoin {
          name = "forge-packages";
          paths = lib.attrValues (lib.filterAttrs (n: v: !lib.hasPrefix "_forge" n) config.packages);
        };
      };
    };
}
