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
          description = "C/C++ library for computational geometry with a focus on algorithms used in geographic information systems (GIS) software";
          homePage = "https://libgeos.org";
          mainProgram = "geos-config";

          source = {
            url = "https://download.osgeo.org/geos/geos-3.9.6.tar.bz2";
            hash = "sha256-jChKNBWS+WDYSBPrujwv1PyesLZlggon9vi+shGrawA=";
          };

          build.standardBuilder = {
            enable = true;
            requirements = {
              native = [
                pkgs.cmake
                pkgs.ninja
              ];
            };
          };
        }
      ];
    };
}
