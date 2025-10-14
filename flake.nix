{
  description = "Nix Forge";

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

        ./outputs/all-apps.nix
        ./outputs/all-packages.nix
      ];

      _module.args.rootPath = ./.;
    };
}
