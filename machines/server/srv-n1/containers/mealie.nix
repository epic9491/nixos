{
  home-manager.users.mealie = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;
      containers.mealie = {
        image = "ghcr.io/mealie-recipes/mealie:v3.23.1@sha256:5fc5cebedddb3952c1ee78f20faf42ab7e49986813fd314745aa97978a4a13eb";
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
