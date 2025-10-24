{
  description = "Nix Forge";

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
      # Uncomment this to enable flake-parts debug.
      # https://flake.parts/options/flake-parts.html?highlight=debug#opt-debug
      # debug = true;

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

        ./outputs/all-apps.nix
        ./outputs/all-packages.nix
      ];

      _module.args.rootPath = ./.;
    };
}
