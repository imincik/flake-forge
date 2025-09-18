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
        packages = [
          pkgs.hello
          pkgs.cowsay
        ];
      };
    };
}
