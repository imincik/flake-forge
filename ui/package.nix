{
  stdenv,

  elmPackages,
  forge-config,
}:

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

    cp -a src/resources $out

    ln -s ${forge-config} $out/forge-config.json 
  '';
}
