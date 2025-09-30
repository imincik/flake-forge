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
      forge.apps = [
        {
          name = "hello";
          version = "1.0.0";
          description = "Say hello in multiple languages.";

          containers = [
            {
              name = "hello-english";
              requirements = [ config.packages.hello ];
              config.Cmd = [
                "hello"
                "--greeting"
                "Hello"
              ];
            }
            {
              name = "hello-italian";
              requirements = [ config.packages.hello ];
              config.Cmd = [
                "hello"
                "--greeting"
                "Ciao"
              ];
            }
            {
              name = "hello-spanish";
              requirements = [ config.packages.hello ];
              config.Cmd = [
                "hello"
                "--greeting"
                "Hola"
              ];
            }
          ];

          composeFile = ''
            services:
              hello-english:
                image: localhost/hello-english:latest
              hello-italian:
                image: localhost/hello-italian:latest
              hello-spanish:
                image: localhost/hello-spanish:latest
          '';
        }
      ];
    };
}
