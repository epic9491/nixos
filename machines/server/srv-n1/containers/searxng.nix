{
  home-manager.users.searxng = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;

      networks.searxng = { };

      containers.searxng = {
        image = "docker.io/searxng/searxng:latest@sha256:55e1fa15a63ff04e79e213e6aa2837549877b0c6d60757cdb633ae9111cb5fea";
        autoStart = true;
        network = "searxng.network";
        ports = [ "127.0.0.1:8082:8080" ];
        volumes = [
          "/var/lib/searxng/config:/etc/searxng:rw"
          "/var/lib/searxng/cache:/var/cache/searxng:rw"
        ];
        environmentFile = [ "/run/secrets/searxng.env" ];
        extraConfig = {
          Container = {
            AddCapability = "CHOWN DAC_OVERRIDE";
            DropCapability = "ALL";
            NoNewPrivileges = true;
          };
          Service.Restart = "always";
          Unit = {
            After = [ "podman-searxng-redis.service" ];
            Wants = [ "podman-searxng-redis.service" ];
          };
        };
      };

      containers.searxng-redis = {
        image = "docker.io/valkey/valkey:8-alpine@sha256:cfb2aa4c8352930130fd45eb231a57310ac326d7323edae12b384b9270c46dda";
        autoStart = true;
        network = "searxng.network";
        networkAlias = [ "redis" ];
        volumes = [ "/var/lib/searxng/redis-data:/data" ];
        exec = "valkey-server --save 30 1 --loglevel warning --maxmemory 256mb --maxmemory-policy allkeys-lru";
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

  sops.secrets."searxng.env" = {
    sopsFile = ../../../../secrets/srv-n1.searxng.env;
    format = "binary";
    owner = "searxng";
    group = "searxng";
    mode = "0400";
  };
}
