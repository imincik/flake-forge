{
  stdenv,

  elmPackages,
  _forge-config,
  _forge-options-apps,
  _forge-options-packages,
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
  '';

  installPhase = ''
    mkdir $out
    mkdir $out/docs

    cp src/index.html $out
    cp build/main.js $out

    cp -a src/resources $out

    ln -s ${_forge-config} $out/forge-config.json 
    ln -s ${_forge-options-apps} $out/docs/options-apps.html
    ln -s ${_forge-options-packages} $out/docs/options-packages.html
  '';
}
