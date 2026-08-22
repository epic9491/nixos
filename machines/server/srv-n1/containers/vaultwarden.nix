{
  home-manager.users.vaultwarden = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.vaultwarden = {
        image = "docker.io/vaultwarden/server:1.37.2@sha256:094b5689ed81549bd293418395c7cf495ae9d960fc2d4928cef2083ef913d912";
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
