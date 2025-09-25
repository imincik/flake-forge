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
          name = "geos-plain-build";
          version = "3.9.6";
          description = "C/C++ library for computational geometry with a focus on algorithms used in geographic information systems (GIS) software";
          homePage = "https://libgeos.org";
          mainProgram = "geos-config";

          source = {
            url = "https://download.osgeo.org/geos/geos-3.9.6.tar.bz2";
            hash = "sha256-jChKNBWS+WDYSBPrujwv1PyesLZlggon9vi+shGrawA=";
          };

          build.plainBuilder = {
            enable = true;
            requirements = {
              native = [
                pkgs.cmake
                pkgs.ninja
              ];
            };
            configure = ''
              mkdir build && cd build

              cmake ''${CMAKE_ARGS} \
                -D CMAKE_BUILD_TYPE=Release \
                -D CMAKE_INSTALL_PREFIX=$out \
                ..
            '';
            build = ''
              make -j ''$NIX_BUILD_CORES
            '';
            check = ''
              ctest --output-on-failure
            '';
            install = ''
              make install -j ''$NIX_BUILD_CORES
            '';
          };

          test.script = ''
            geos-config --version | grep -E "[0-9]\.[0-9]\.[0-9]"
          '';
        }
      ];
    };
}
