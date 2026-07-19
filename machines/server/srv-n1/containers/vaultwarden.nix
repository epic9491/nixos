{
  home-manager.users.vaultwarden = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.vaultwarden = {
        image = "docker.io/vaultwarden/server@sha256:d626d04934cd1192ad8ced1adb975099fca78cec33ab467d2d3c923cde7f3b0c";
        autoStart = true;
        ports = [ "127.0.0.1:8000:8000" ];
        volumes = [ "/var/lib/vaultwarden/data:/data:Z" ];
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

  sops.secrets."vaultwarden.env" = {
    sopsFile = ../../../../secrets/srv-n1.vaultwarden.env;
    format = "binary";
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "0400";
  };
}
