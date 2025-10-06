{
  description = "Flake Forge - the software distribution system";

  nixConfig = {
    extra-substituters = [ "https://flake-forge.cachix.org" ];
    extra-trusted-public-keys = [
      "flake-forge.cachix.org-1:cu8to1JK8J70jntSwC0Z2Uzu6DpwgcWTS3xiiye3Lyw="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:vic/import-tree";

    nix-utils = {
      url = "github:imincik/nix-utils";
      flake = false;
    };

    # git-hooks = {
    #   url = "github:cachix/git-hooks.nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:

    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        # "aarch64-linux"
        # "aarch64-darwin"
        # "x86_64-darwin"
      ];

      imports = [
        ./forge/modules/apps.nix
        ./forge/modules/packages.nix
        ./forge/packages.nix
        ./ui/develop.nix
        ./checks.nix

        (inputs.import-tree ./outputs)
      ];

      _module.args.rootPath = ./.;
    };
}
