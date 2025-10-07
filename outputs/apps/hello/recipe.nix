{
  config,
  lib,
  pkgs,
  ...
}:

{
  forge.apps = [
    {
      name = "hello";
      version = "1.0.0";
      description = "Say hello in multiple languages.";

      programs = {
        requirements = [
          config.packages.hello
        ];
      };

      containers = [
        {
          name = "hello-english";
          requirements = [ config.packages.hello ];
          config.CMD = [
            "hello"
            "--greeting"
            "Hello"
          ];
        }
        {
          name = "hello-italian";
          requirements = [ config.packages.hello ];
          config.CMD = [
            "hello"
            "--greeting"
            "Ciao"
          ];
        }
        {
          name = "hello-spanish";
          requirements = [ config.packages.hello ];
          config.CMD = [
            "hello"
            "--greeting"
            "Hola"
          ];
        }
      ];

      composeFile = ./compose.yaml;
    }
  ];
}
