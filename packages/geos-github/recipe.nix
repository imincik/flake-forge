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
          name = "geos-github";
          version = "2025-09-23";
          description = "C/C++ library for computational geometry with a focus on algorithms used in geographic information systems (GIS) software";
          homePage = "https://libgeos.org";

          source = {
            github = "libgeos/geos/69cce6b85195d4010e5b066f62a4c1137da92173";
            hash = "sha256-sYMzgV+B3iA7gj3hP9zpYPN7N2t5NRMVJAJ1dga3neM=";
          };

          build.defaultBuilder = {
            enable = true;
            requirements = {
              native = [ pkgs.cmake ];
            };
          };
        }
      ];
    };
}
