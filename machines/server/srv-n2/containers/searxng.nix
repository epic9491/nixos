{
  home-manager.users.searxng = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;

      networks.searxng = { };

      containers.searxng = {
        image = "docker.io/searxng/searxng:latest@sha256:af6bde1e3590f91be5b7c4e393b3bff82ada4b93d60fc10806fe1ed4ba147d4d";
        autoStart = true;
        network = "searxng.network";
        ports = [ "127.0.0.1:8082:8080" ];
        volumes = [
          "/var/lib/searxng/config:/etc/searxng:rw"
          "/var/lib/searxng/cache:/var/cache/searxng:rw"
        ];
        environment = {
          SEARXNG_BASE_URL = "https://libresearch.space/";
          SEARXNG_LIMITER = "true";
          SEARXNG_PUBLIC_INSTANCE = "true";
          SEARXNG_VALKEY_URL = "valkey://redis:6379/0";
          # a solved anubis challenge only replays a GET
          SEARXNG_METHOD = "GET";
        };
        environmentFile = [ "/run/secrets/searxng.env" ];
        extraConfig = {
          Container = {
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
        image = "docker.io/valkey/valkey:8-alpine@sha256:a038175878d66b9d274fbf8be73c0305e93798b83917647f167e18cef3c71eec";
        autoStart = true;
        network = "searxng.network";
        networkAlias = [ "redis" ];
        volumes = [ "/var/lib/searxng/redis-data:/data" ];
        exec = "valkey-server --save 30 1 --loglevel warning --maxmemory 256mb --maxmemory-policy allkeys-lru";
        extraConfig = {
          Container = {
            DropCapability = "ALL";
            AddCapability = [
              "CHOWN"
              "DAC_OVERRIDE"
              "FOWNER"
              "SETGID"
              "SETUID"
            ];
            NoNewPrivileges = false;
          };
          Service.Restart = "always";
        };
      };
    };
  };

  sops.secrets."searxng.env" = {
    sopsFile = ../../../../secrets/srv-n2.searxng.env;
    format = "binary";
    owner = "searxng";
    group = "searxng";
    mode = "0400";
  };
}
