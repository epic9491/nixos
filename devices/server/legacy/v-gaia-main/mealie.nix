{ config, ... }:
{
  containers.mealie = {
    autoStart = true;
    config = { config, ... }: {
      system.stateVersion = "25.11";
      users.users.mealie = {
        isSystemUser = true;
        group = "mealie";
      };
      users.groups.mealie = {};
      services.mealie = {
        enable = true;
        settings = {
          API_PORT = 6968;
          TOKEN_TIME = 720;
          TZ = "America/Chicago";
        };
      };
    };
  };
}
