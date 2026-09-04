{
  home-manager.users.mealie = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.mealie = {
        image = "ghcr.io/mealie-recipes/mealie:v3.25.1@sha256:6066c29eca95a6cac640ecadf734799522f3b646ee4a714e0d13ce795d989ba2";
        autoStart = true;
        ports = [ "127.0.0.1:9000:9000" ];
        volumes = [ "/var/lib/mealie/data:/app/data:Z" ];
        environmentFile = [ "/run/secrets/mealie.env" ];
        environment = {
          ALLOW_SIGNUP = "false";
          PUID = 1000;
          PGID = 1000;
          TZ = "America/New_York";
          TOKEN_TIME = 720;
        };
        extraConfig = {
          Container = {
            AddCapability = "CHOWN SETGID SETUID";
            DropCapability = "ALL";
            NoNewPrivileges = true;
          };
          Service.Restart = "always";
        };
      };
    };
  };

  sops.secrets."mealie.env" = {
    sopsFile = ../../../../secrets/srv-n1.mealie.env;
    format = "binary";
    owner = "mealie";
    group = "mealie";
    mode = "0400";
  };
}
