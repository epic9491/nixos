{ config, ... }:
{
  containers.lubelogger = {
    autoStart = true;
    config = { config, ... }: {
      system.stateVersion = "25.11";
      users.users.lubelogger = {
        isSystemUser = true;
        group = "lubelogger";
      };
      users.groups.lubelogger = {};
      services.lubelogger = {
        enable = true;
        user = "lubelogger";
        group = "lubelogger";
        port = 6969;
      };
    };
  };
}
