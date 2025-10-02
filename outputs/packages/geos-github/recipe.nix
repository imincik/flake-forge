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
          description = "GEOS package built from GitHub using standardBuilder.";
          homePage = "https://libgeos.org";
          mainProgram = "geosop";

          source = {
            github = "libgeos/geos/69cce6b85195d4010e5b066f62a4c1137da92173";
            hash = "sha256-sYMzgV+B3iA7gj3hP9zpYPN7N2t5NRMVJAJ1dga3neM=";
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
