{ inputs, ... }:

{
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

          composeFile = ''
            services:
              api:
                image: localhost/api:latest
                environment:
                  - DB_HOST=database
                  - DB_NAME=postgres
                  - DB_USER=postgres
                ports:
                  - 5000:5000
                profiles:
                  - services

              database:
                image: postgres:latest
                environment:
                  - POSTGRES_HOST_AUTH_METHOD=trust
                ports:
                  - 5432:5432
                profiles:
                  - services
          '';
        }
      ];
    };
}
