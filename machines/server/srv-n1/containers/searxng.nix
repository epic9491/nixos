{
  home-manager.users.searxng = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;

      networks.searxng = { };

      containers.searxng = {
        image = "docker.io/searxng/searxng:latest@sha256:addd2cf36efb4b9815a2820a522aef7cce4da0d1c0e4527f6675f5663332fc9b";
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
        image = "docker.io/valkey/valkey:8-alpine@sha256:e0eb7c480958d32bdc4357a74bdd70653ae15f2f9b4c93c4a5a9fad1dc471c84";
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
