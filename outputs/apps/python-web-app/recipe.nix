{
  config,
  lib,
  pkgs,
  mypkgs,
  ...
}:

{
  forge.apps = [
    {
      name = "python-web-app";
      version = "1.0.0";
      description = "Simple web application with database backend.";

      programs = {
        requirements = [
          pkgs.curl
        ];
      };

      containers = [
        {
          name = "api";
          requirements = [ mypkgs.python-web ];
          config.CMD = [
            "python-web"
          ];
        }
      ];

      composeFile = ./compose.yaml;
    }
  ];
}
