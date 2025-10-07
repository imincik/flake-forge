{
  config,
  lib,
  pkgs,
  ...
}:

{
  forge.apps = [
    {
      name = "python-web";
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
          requirements = [ config.packages.python-web ];
          config.CMD = [
            "python-web"
          ];
        }
      ];

      composeFile = ./compose.yaml;
    }
  ];
}
