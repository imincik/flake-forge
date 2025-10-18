{
  stdenv,

  elmPackages,
  _forge-config,
  _forge-options,
}:

stdenv.mkDerivation {
  # FIXME: avoid building with disabled sandbox
  # nix build .#forge-config --option sandbox relaxed --builders ""
  __noChroot = true;

  pname = "forge-ui";
  version = "0.1.0";

  src = ./.;

  buildInputs = [
    elmPackages.elm
  ];

  buildPhase = ''
    export HOME=$(mktemp -d)
    mkdir build

    elm make src/Main.elm --optimize --output=build/main.js
    elm make src/OptionsMain.elm --optimize --output=build/options.js
  '';

  installPhase = ''
    mkdir $out
    mkdir $out/docs

    cp src/index.html $out
    cp build/main.js $out
    cp src/options.html $out
    cp build/options.js $out

    cp -a src/resources $out

    ln -s ${_forge-config} $out/forge-config.json 
    ln -s ${_forge-options} $out/options.json
  '';
}
