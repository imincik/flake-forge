{ inputs, flake-parts-lib, ... }:

{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      optionsDoc =
        modules:
        let
          eval = lib.evalModules {
            modules = modules;
            specialArgs = { inherit flake-parts-lib; };
          };
          doc = pkgs.nixosOptionsDoc {
            warningsAreErrors = false;
            options = lib.removeAttrs eval.options [ "_module" ];
            transformOptions =
              opt:
              (
                opt
                // {
                  name = lib.removePrefix "perSystem.forge." opt.name;
                  declarations = [ ];
                }
              );
          };
          html = pkgs.runCommand "options.html" { buildInputs = [ pkgs.pandoc ]; } ''
            pandoc ${doc.optionsCommonMark} -o $out
          '';
        in
        html;
    in

    {
      packages = {
        _forge-config = pkgs.writeTextFile {
          name = "forge-config.json";
          text = builtins.toJSON config.forge;
        };

        _forge-options-apps = optionsDoc [ ./modules/apps.nix ];
        _forge-options-packages = optionsDoc [ ./modules/packages.nix ];

        _forge-ui = pkgs.callPackage ../ui/package.nix {
          inherit (config.packages) _forge-config _forge-options-apps _forge-options-packages;
        };
      };
    };
}
