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
      forgePackages = lib.filterAttrs (n: v: !lib.hasPrefix "_forge" n) config.packages;

      # All packages containing test attribute
      forgePackageTests = lib.filterAttrs (_: v: v != null) (
        lib.mapAttrs (
          name: package: if lib.hasAttr "test" package then package.test else null
        ) config.packages
      );

      # All apps containing programs attribute
      forgeAppPrograms = lib.filterAttrs (_: v: v != null) (
        lib.mapAttrs (
          name: package: if lib.hasAttr "programs" package then package.programs else null
        ) config.packages
      );

      # All apps containing vm attribute
      forgeAppVms = lib.filterAttrs (_: v: v != null) (
        lib.mapAttrs (name: package: if lib.hasAttr "vm" package then package.vm else null) config.packages
      );
    in

    {
      checks = {
        inherit (config.packages) _forge-config _forge-options-apps _forge-options-packages;
        # inherit (config.packages) _forge-ui;
      }
      // forgePackages
      // forgePackageTests
      // forgeAppPrograms
      // forgeAppVms;
    };
}
