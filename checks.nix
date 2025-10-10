{
  inputs,
  config,
  lib,
  ...
}:

{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:

    let
      # All output packages
      _forge-packages = lib.filterAttrs (n: v: !lib.hasPrefix "_forge" n) config.packages;

      # All packages containing test attribute
      _forge-tests = lib.filterAttrs (_: v: v != null) (
        lib.mapAttrs (
          name: package: if lib.hasAttr "test" package then package.test else null
        ) config.packages
      );
    in

    {
      checks = {
        inherit (config.packages) _forge-config;
        # inherit (config.packages) _forge-ui;
      }
      // _forge-packages
      // _forge-tests;
    };
}
