{
  home-manager.users.vaultwarden = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.vaultwarden = {
        image = "docker.io/vaultwarden/server:latest";
        autoStart = true;
        autoUpdate = "registry";
        ports = [ "127.0.0.1:8000:8000" ];
        volumes = [ "/srv/vaultwarden/data:/data:Z" ];
        environmentFile = [ "/run/secrets/vaultwarden.env" ];
        environment = {
          SIGNUPS_ALLOWED = "false";
          ROCKET_PORT = "8000";
          WEBSOCKET_ENABLED = "true";
        };
        extraConfig.Service.Restart = "always";
      };
    };
  };

  age.secrets."vaultwarden.env" = {
    file = ../../../../../secrets/srv-n1.vaultwarden.env.age;
    path = "/run/secrets/vaultwarden.env";
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "0400";
  };
}
