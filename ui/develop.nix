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
      devShells.ui = pkgs.mkShell {
        packages = with pkgs; [
          entr
          elmPackages.elm
          jq
          python3Packages.python
        ];

        shellHook =
          ''
            function dev-help {
              echo -e "\nWelcome to the UI development environment !"
              echo
              echo "'cd ui' first"
              echo
              echo "Re-generate forge-config file:"
              echo "  cat \$(nix build .#_forge-config --print-out-paths) | jq > src/forge-config.json"
              echo
              echo "Launch Python web server:"
              echo "  python3 -m http.server &"
              echo
              echo "Re-build Elm app on change:"
              echo "  find src/ -name "*.elm" | entr -rn elm make src/Main.elm --output=src/main.js"
              echo
              echo "Run 'dev-help' to see this message again."
            }

            dev-help
          '';
      };
    };
}
