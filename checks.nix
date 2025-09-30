{ inputs, config, ... }:

{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:

    {
      checks = {
        inherit (config.packages) _forge-config;
        inherit (config.packages) _forge-packages;
        # inherit (config.packages) _forge-ui;
      };
    };
}
