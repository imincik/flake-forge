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
        enable = true;

        packages = {
          builders = {
            default = [
              {
                name = "hello";
                source = {
                  url = "mirror://gnu/hello/hello-2.12.1.tar.gz";
                  hash = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
                };
              }
              {
                name = "geos";
                source = {
                  url = "https://download.osgeo.org/geos/geos-3.9.6.tar.bz2";
                  hash = "sha256-jChKNBWS+WDYSBPrujwv1PyesLZlggon9vi+shGrawA=";
                };
                requirements = {
                  build = [ pkgs.cmake ];
                };
              }
            ];
          };

          nixpkgs = [
            pkgs.cowsay
            pkgs.jq
          ];
        };
      };
    };
}
