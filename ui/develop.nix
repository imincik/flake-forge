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
      devShells.ui = pkgs.mkShell {
        packages = with pkgs; [
          entr
          jq
          live-server

          elmPackages.elm
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
              echo "Re-generate options documentation:"
              echo "  cat \$(nix build .#_forge-options --print-out-paths) | jq > src/options.json"
              echo
              echo "Launch live server:"
              echo "  live-server --host=127.0.0.1 --open=/index.html src/ & echo \$! > live-server.pid"
              echo
              echo "Re-build main app on change:"
              echo "  find src/ -name "*.elm" | entr -rn elm make src/Main.elm --output=src/main.js"
              echo
              echo "Re-build options browser on change:"
              echo "  find src/ -name "*.elm" | entr -rn elm make src/OptionsMain.elm --output=src/options.js"
              echo
              echo "Run 'dev-help' to see this message again."
            }

            function cleanup {
              echo "Stopping live-server ..."
              kill -9 $(cat live-server.pid) || echo ".. failed to stop live-server"
              rm -f live-server.pid
            }

            trap cleanup EXIT

            dev-help
          '';
      };
    };
}
