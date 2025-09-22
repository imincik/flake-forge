{
  stdenv,
  writeTextFile,

  elmPackages,

  forgeConfig,
}:

let
  forgeConfigFile = writeTextFile {
    name = "forge-config.json";
    text = builtins.toJSON forgeConfig;
  };

in
stdenv.mkDerivation {
  # FIXME: avoid this
  # nix build .#forge-config --option sandbox relaxed --builders ""
  __noChroot = true;

  pname = "flake-forge-ui";
  version = "0.1.0";

  src = ./.;

  buildInputs = [
    elmPackages.elm
  ];

  buildPhase = ''
    export HOME=$(mktemp -d)
    mkdir build

    elm make src/Main.elm --optimize --output=build/main.js
  '';

  installPhase = ''
    mkdir $out
    cp src/index.html $out
    cp build/main.js $out

    ln -s ${forgeConfigFile} $out/forge-config.json 
  '';
}
