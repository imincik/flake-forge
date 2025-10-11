{
  config,
  lib,
  pkgs,
  mypkgs,
  ...
}:

{
  name = "hello-app";
  version = "1.0.0";
  description = "Say hello in multiple languages.";

  programs = {
    requirements = [
      mypkgs.hello
    ];
  };

  containers = {
    images = [
      {
        name = "hello-english";
        requirements = [ mypkgs.hello ];
        config.CMD = [
          "hello"
          "--greeting"
          "Hello"
        ];
      }
      {
        name = "hello-italian";
        requirements = [ mypkgs.hello ];
        config.CMD = [
          "hello"
          "--greeting"
          "Ciao"
        ];
      }
      {
        name = "hello-spanish";
        requirements = [ mypkgs.hello ];
        config.CMD = [
          "hello"
          "--greeting"
          "Hola"
        ];
      }
    ];
    composeFile = ./compose.yaml;
  };

  vm = {
    enable = true;
    name = "hello";
    requirements = [
      mypkgs.hello
    ];
  };
}
