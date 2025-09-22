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
          name = "hello";
          version = "2.12.1";
          description = "My Hello package";
          source = {
            url = "mirror://gnu/hello/hello-2.12.1.tar.gz";
            hash = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
          };
          build.defaultBuilder = {
            enable = true;
          };
        }
      ];
    };
}
