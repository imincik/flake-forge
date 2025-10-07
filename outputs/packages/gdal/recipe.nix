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
      version = "2025-10-05";
      description = "GDAL package built from GitHub using standardBuilder.";
      homePage = "https://gdal.org";
      mainProgram = "gdalinfo";

      source = {
        github = "OSGeo/gdal/3679e5e4511ae8b4a956ded7ef7be23fdb86b7db";
        hash = "sha256-0cHD1+vEAahllGNOe6Y4uec44HmCvlJphRj8JPJzOXc=";
      };

      build.standardBuilder = {
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

      test.script = ''
        gdalinfo --version | grep -E "GDAL.[0-9]*\.[0-9]*\.[0-9]*"
      '';
    }
  ];
}
