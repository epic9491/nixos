{
  home-manager.users."immich-public" = { ... }: {
    home.stateVersion = "25.05";

    services.podman = {
      enable = true;

      networks.immich-public = { };

      containers.immich-public-server = {
        image = "ghcr.io/immich-app/immich-server:v3@sha256:c716dc20f957aafd89fa9d284a2ec63e25c9e2d8d8e87c6197d540a3dce237db";
        autoStart = true;
        network = "immich-public.network";
        ports = [ "127.0.0.1:2284:2283" ];
        volumes = [
          "/var/lib/immich-public/library:/data"
          "/etc/localtime:/etc/localtime:ro"
        ];
        environmentFile = [ "/run/secrets/immich-public.env" ];
        extraConfig = {
          Container = {
            DropCapability = "ALL";
            NoNewPrivileges = true;
          };
          Service.Restart = "always";
          Unit = {
            After = [
              "podman-immich-public-redis.service"
              "podman-immich-public-database.service"
            ];
            Wants = [
              "podman-immich-public-redis.service"
              "podman-immich-public-database.service"
            ];
          };
        };
      };

      containers.immich-public-machine-learning = {
        image = "ghcr.io/immich-app/immich-machine-learning:v3@sha256:5a0839dc5303cd7215bcd2180a26aed3af41675aefb3e75e5157e9f10ad16e6e";
        autoStart = true;
        network = "immich-public.network";
        networkAlias = [ "immich-machine-learning" ];
        volumes = [ "/var/lib/immich-public/model-cache:/cache" ];
        environmentFile = [ "/run/secrets/immich-public.env" ];
        extraConfig = {
          Container = {
            DropCapability = "ALL";
            NoNewPrivileges = true;
          };
          Service.Restart = "always";
        };
      };

      containers.immich-public-redis = {
        image = "docker.io/valkey/valkey:8@sha256:495e4fecdc98ee48a20b207726caa5ab6451e0fac3642a9be10d9e70b3068df6";
        autoStart = true;
        network = "immich-public.network";
        networkAlias = [ "redis" ];
        extraConfig = {
          Container = {
            AddCapability = "CHOWN SETGID SETUID";
            DropCapability = "ALL";
            NoNewPrivileges = true;
          };
          Service.Restart = "always";
        };
      };

      containers.immich-public-database = {
        image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
        autoStart = true;
        network = "immich-public.network";
        networkAlias = [ "database" ];
        volumes = [ "/var/lib/immich-public/postgres:/var/lib/postgresql/data" ];
        environmentFile = [ "/run/secrets/immich-public.env" ];
        extraPodmanArgs = [ "--shm-size=128mb" ];
        extraConfig = {
          Container = {
            AddCapability = "CHOWN DAC_OVERRIDE FOWNER SETGID SETUID";
            DropCapability = "ALL";
            NoNewPrivileges = true;
          };
          Service.Restart = "always";
        };
      };
    };
  };

  sops.secrets."immich-public.env" = {
    sopsFile = ../../../../secrets/srv-n1.immich-public.env;
    format = "binary";
    owner = "immich-public";
    group = "immich-public";
    mode = "0400";
  };
}
