{
  home-manager.users.immich = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;

      networks.immich = { };

      containers.immich-server = {
        image = "ghcr.io/immich-app/immich-server:v3";
        autoStart = true;
        autoUpdate = "registry";
        network = "immich.network";
        ports = [ "127.0.0.1:2283:2283" ];
        volumes = [
          "/var/lib/immich/library:/data"
          "/mnt/photos/Apple-Photos:/external/apple-photos:ro"
          "/etc/localtime:/etc/localtime:ro"
        ];
        environmentFile = [ "/run/secrets/immich.env" ];
        extraConfig = {
          Service.Restart = "always";
          Unit = {
            After = [
              "podman-immich-redis.service"
              "podman-immich-database.service"
            ];
            Wants = [
              "podman-immich-redis.service"
              "podman-immich-database.service"
            ];
          };
        };
      };

      containers.immich-machine-learning = {
        image = "ghcr.io/immich-app/immich-machine-learning:v3";
        autoStart = true;
        autoUpdate = "registry";
        network = "immich.network";
        networkAlias = [ "immich-machine-learning" ];
        volumes = [ "/var/lib/immich/model-cache:/cache" ];
        environmentFile = [ "/run/secrets/immich.env" ];
        extraConfig.Service.Restart = "always";
      };

      containers.immich-redis = {
        image = "docker.io/valkey/valkey:8@sha256:81db6d39e1bba3b3ff32bd3a1b19a6d69690f94a3954ec131277b9a26b95b3aa";
        autoStart = true;
        network = "immich.network";
        networkAlias = [ "redis" ];
        extraConfig.Service.Restart = "always";
      };

      containers.immich-database = {
        image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
        autoStart = true;
        network = "immich.network";
        networkAlias = [ "database" ];
        volumes = [ "/var/lib/immich/postgres:/var/lib/postgresql/data" ];
        environmentFile = [ "/run/secrets/immich.env" ];
        extraPodmanArgs = [ "--shm-size=128mb" ];
        extraConfig.Service.Restart = "always";
      };
    };
  };

  age.secrets."immich.env" = {
    file = ../../../../secrets/srv-n1.immich.env.age;
    path = "/run/secrets/immich.env";
    owner = "immich";
    group = "immich";
    mode = "0400";
  };
}
