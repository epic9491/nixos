{
  home-manager.users.mealie = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.mealie = {
        image = "ghcr.io/mealie-recipes/mealie:latest";
        autoStart = true;
        autoUpdate = "registry";
        ports = [ "127.0.0.1:9000:9000" ];
        volumes = [ "/srv/mealie/data:/app/data:Z" ];
        environment = {
          ALLOW_SIGNUP = "false";
          PUID = 1000;
          PGID = 1000;
          TZ = "America/New_York";
          TOKEN_TIME = 720;
        };
        extraConfig.Service.Restart = "always";
      };
    };
  };
}
