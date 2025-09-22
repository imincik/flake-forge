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
      forge.packages = [
        {
          name = "geos";
          version = "3.9.6";
          source = {
            url = "https://download.osgeo.org/geos/geos-3.9.6.tar.bz2";
            hash = "sha256-jChKNBWS+WDYSBPrujwv1PyesLZlggon9vi+shGrawA=";
          };
          build.defaultBuilder = {
            enable = true;
            requirements = {
              host = [ pkgs.cmake ];
            };
          };
        }
      ];
    };
}
