{ inputs, ... }:

{
  debug = true;

  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    {
      repo = {
        packages.builders.default = [
          {
            name = "gdal";
            version = "3.9.3";
            source = {
              url = "https://download.osgeo.org/gdal/3.9.3/gdal-3.9.3.tar.gz";
              hash = "sha256-8pPYzMa5j2F9uI+Fk+rjf35LMtSaYVssulztEse+va4=";
            };
            requirements = {
              host = [ pkgs.cmake ];
              build = [
                pkgs.proj
              ];
            };
          }
        ];
      };
    };
}
