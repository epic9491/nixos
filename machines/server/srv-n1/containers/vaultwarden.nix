{
  home-manager.users.vaultwarden = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.vaultwarden = {
        image = "docker.io/vaultwarden/server@sha256:e6443e3d5ed8fcee2204b89ec778d7f24d0173bcc42d1ea34f990304f5f63f51";
        autoStart = true;
        ports = [ "127.0.0.1:8000:8000" ];
        volumes = [ "/var/lib/vaultwarden/data:/data:Z" ];
        environmentFile = [ "/run/secrets/vaultwarden.env" ];
        environment = {
          SIGNUPS_ALLOWED = "false";
          ROCKET_PORT = "8000";
          WEBSOCKET_ENABLED = "true";
        };
        extraConfig = {
          Container = {
            DropCapability = "ALL";
            NoNewPrivileges = true;
          };
          Service.Restart = "always";
        };
      };
    };
  };

  sops.secrets."vaultwarden.env" = {
    sopsFile = ../../../../secrets/srv-n1.vaultwarden.env;
    format = "binary";
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "0400";
  };
}
