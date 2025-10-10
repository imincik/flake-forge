{
  config,
  lib,
  pkgs,
  mypkgs,
  ...
}:

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

  vm = {
    enable = true;
    name = "database";
    config.system = {
      # database service
      services.postgresql.enable = true;
      services.postgresql.enableTCPIP = true;
      services.postgresql.authentication = ''
        local all all trust
        host all all 0.0.0.0/0 trust
        host all all ::0/0 trust
      '';
      # api service
      systemd.services.api.script = "${mypkgs.python-web}/bin/python-web";
      systemd.services.api.wantedBy = [
        "multi-user.target"
      ];
    };
    config.ports = [
      "5000:5000"
    ];
  };
}
