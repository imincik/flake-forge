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
          name = "gdal";
          version = "3.9.3";
          description = "Translator library for raster geospatial data formats";
          homePage = "https://gdal.org";

          source = {
            url = "https://download.osgeo.org/gdal/3.9.3/gdal-3.9.3.tar.gz";
            hash = "sha256-8pPYzMa5j2F9uI+Fk+rjf35LMtSaYVssulztEse+va4=";
          };

          build.defaultBuilder = {
            enable = true;
            requirements = {
              native = [
                pkgs.cmake
              ];
              build = [
                pkgs.proj
              ];
            };
          };
        }
      ];
    };
}
