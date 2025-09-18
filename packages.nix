{ inputs, ... }:

{
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
            default = {
              name = "hello";
              source = {
                url = "mirror://gnu/hello/hello-2.12.1.tar.gz";
                hash = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
              };
            };
          };

          nixpkgs = [
            pkgs.cowsay
            pkgs.jq
          ];
        };
      };
    };
}
